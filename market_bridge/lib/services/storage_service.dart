// lib/services/storage_service.dart
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload a file to Firebase Storage
  /// Returns the download URL if successful, null otherwise
  Future<String?> uploadFile({
    required File file,
    required String folder,
    Function(double)? onProgress,
  }) async {
    try {
      // Create unique filename
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final extension = file.path.split('.').last;

      // Create storage reference
      final storageRef = _storage.ref().child('$folder/$fileName.$extension');

      // Upload file
      final uploadTask = storageRef.putFile(file);

      // Listen to upload progress if callback provided
      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }

      // Wait for upload to complete
      await uploadTask;

      // Get and return download URL
      final downloadURL = await storageRef.getDownloadURL();
      debugPrint('✅ File uploaded successfully: $downloadURL');
      return downloadURL;
    } catch (e) {
      debugPrint('❌ Error uploading file: $e');
      return null;
    }
  }

  /// Delete a file from Firebase Storage using its URL
  Future<bool> deleteFile(String fileUrl) async {
    try {
      final ref = _storage.refFromURL(fileUrl);
      await ref.delete();
      debugPrint('✅ File deleted successfully');
      return true;
    } catch (e) {
      debugPrint('⚠️ Error deleting file: $e');
      return false;
    }
  }

  /// Upload produce image
  Future<String?> uploadProduceImage(
      File imageFile, {
        Function(double)? onProgress,
      }) async {
    return uploadFile(
      file: imageFile,
      folder: 'uploads/produce_images',
      onProgress: onProgress,
    );
  }

  /// Upload profile image
  Future<String?> uploadProfileImage(
      File imageFile, {
        Function(double)? onProgress,
      }) async {
    return uploadFile(
      file: imageFile,
      folder: 'uploads/profile_images',
      onProgress: onProgress,
    );
  }

  /// Get file metadata
  Future<FullMetadata?> getFileMetadata(String fileUrl) async {
    try {
      final ref = _storage.refFromURL(fileUrl);
      return await ref.getMetadata();
    } catch (e) {
      debugPrint('Error getting file metadata: $e');
      return null;
    }
  }

  /// List all files in a folder
  Future<List<String>> listFiles(String folder) async {
    try {
      final ref = _storage.ref().child(folder);
      final result = await ref.listAll();

      List<String> urls = [];
      for (var item in result.items) {
        final url = await item.getDownloadURL();
        urls.add(url);
      }

      return urls;
    } catch (e) {
      debugPrint('Error listing files: $e');
      return [];
    }
  }
}