const functions = require("firebase-functions");
const admin = require("firebase-admin");
const {
  onDocumentCreated,
  onDocumentUpdated,
} = require("firebase-functions/v2/firestore");
const { onSchedule } = require("firebase-functions/v2/scheduler");

admin.initializeApp();

/* ================================
   CALLABLE: Send Welcome Notification
================================ */

exports.sendWelcomeNotification = functions.https.onCall(
  async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "User must be authenticated to call this function",
      );
    }

    const userName = data.userName;
    const userRole = data.userRole;

    if (!userName || !userRole) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Missing required fields: userName and userRole",
      );
    }

    const message =
      `Welcome to MarketBridge, ${userName}! ` +
      `You're registered as a ${userRole}.`;

    return {
      success: true,
      message,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    };
  },
);

/* ================================
   FIRESTORE: Product Created
================================ */

exports.onProductCreated = onDocumentCreated(
  {
    document: "products/{productId}",
    region: "us-central1",
  },
  async (event) => {
    const snap = event.data;
    const productData = snap.data();
    const productId = event.params.productId;

    try {
      await snap.ref.update({
        createdAtServer: admin.firestore.FieldValue.serverTimestamp(),
        productId,
        verified: false,
        trending: false,
      });

      if (productData.ownerId) {
        const ownerRef = admin
          .firestore()
          .collection("users")
          .doc(productData.ownerId);

        const ownerDoc = await ownerRef.get();

        if (ownerDoc.exists) {
          await ownerRef.update({
            totalListings: admin.firestore.FieldValue.increment(1),
            lastListingAt: admin.firestore.FieldValue.serverTimestamp(),
          });
        }
      }

      return null;
    } catch (error) {
      return null;
    }
  },
);

/* ================================
   FIRESTORE: Product Updated
================================ */

exports.onProductUpdated = onDocumentUpdated(
  {
    document: "products/{productId}",
    region: "us-central1",
  },
  async (event) => {
    const beforeData = event.data.before.data();
    const afterData = event.data.after.data();

    const priceBefore = beforeData.price || 0;
    const priceAfter = afterData.price || 0;

    if (priceBefore === 0) {
      return null;
    }

    const priceChange =
      Math.abs(priceAfter - priceBefore) / priceBefore;

    if (priceChange > 0.1) {
      await event.data.after.ref.update({
        lastPriceUpdate: admin.firestore.FieldValue.serverTimestamp(),
        priceChangePercent: (priceAfter - priceBefore) / priceBefore,
      });
    }

    return null;
  },
);

/* ================================
   FIRESTORE: User Created
================================ */

exports.onUserCreated = onDocumentCreated(
  {
    document: "users/{userId}",
    region: "us-central1",
  },
  async (event) => {
    const snap = event.data;
    const userData = snap.data();
    const userId = event.params.userId;

    try {
      await snap.ref.update({
        stats: {
          totalListings: 0,
          totalOrders: 0,
          totalSpent: 0,
          rating: 0,
          reviewCount: 0,
        },
        lastActive: admin.firestore.FieldValue.serverTimestamp(),
        accountStatus: "active",
      });

      await admin.firestore().collection("notifications").add({
        userId,
        title: "Welcome to MarketBridge!",
        message:
          `Welcome ${userData.name}! ` +
          "Start exploring fresh produce from local farmers.",
        type: "welcome",
        read: false,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      return null;
    } catch (error) {
      return null;
    }
  },
);

/* ================================
   CALLABLE: Market Statistics
================================ */

exports.getMarketStatistics = functions.https.onCall(async () => {
  try {
    const productsSnapshot = await admin
      .firestore()
      .collection("products")
      .where("inStock", "==", true)
      .get();

    const farmersSnapshot = await admin
      .firestore()
      .collection("users")
      .where("role", "==", "farmer")
      .get();

    const buyersSnapshot = await admin
      .firestore()
      .collection("users")
      .where("role", "==", "buyer")
      .get();

    let totalPriceChange = 0;
    let count = 0;

    productsSnapshot.forEach((doc) => {
      const data = doc.data();
      if (typeof data.priceChangePercent === "number") {
        totalPriceChange += data.priceChangePercent;
        count += 1;
      }
    });

    const avg =
      count > 0 ? (totalPriceChange / count) * 100 : 0;

    return {
      totalProducts: productsSnapshot.size,
      totalFarmers: farmersSnapshot.size,
      totalBuyers: buyersSnapshot.size,
      averagePriceChange: `${avg.toFixed(2)}%`,
      timestamp: new Date().toISOString(),
    };
  } catch (error) {
    throw new functions.https.HttpsError("internal", error.message);
  }
});

/* ================================
   SCHEDULED: Daily Reset (v2)
================================ */

exports.dailyPriceUpdate = onSchedule(
  {
    schedule: "0 0 * * *",
    timeZone: "Asia/Kolkata",
  },
  async () => {
    try {
      const productsSnapshot = await admin
        .firestore()
        .collection("products")
        .get();

      const batch = admin.firestore().batch();

      productsSnapshot.forEach((doc) => {
        batch.update(doc.ref, {
          dailyViews: 0,
          lastDailyReset: admin.firestore.FieldValue.serverTimestamp(),
        });
      });

      await batch.commit();
      return null;
    } catch (error) {
      return null;
    }
  },
);

/* ================================
   HTTP: Health Check
================================ */

exports.healthCheck = functions.https.onRequest((req, res) => {
  res.json({
    status: "healthy",
    timestamp: new Date().toISOString(),
    version: "1.0.0",
  });
});
