import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> register(
    String name,
    String email,
    String password,
  ) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _db.collection('users').doc(cred.user!.uid).set({
        'name': name,
        'email': email,
        'instagram': '',
        'createdAt': FieldValue.serverTimestamp(),
      });
      return cred;
    } on FirebaseAuthException catch (e) {
      final msg = e.message ?? '';
      if (msg.contains('API key not valid') ||
          msg.contains('invalid-api-key') ||
          msg.contains('invalid API key')) {
        throw FirebaseAuthException(
          code: 'invalid-api-key',
          message:
              'API key Firebase tidak valid. Periksa file google-services.json dan pastikan menggunakan konfigurasi Firebase yang benar.',
        );
      }
      throw FirebaseAuthException(
        code: e.code,
        message: _firebaseErrorMessage(e),
      );
    } catch (e) {
      final text = e.toString();
      if (text.contains('API key not valid') ||
          text.contains('invalid-api-key') ||
          text.contains('invalid API key')) {
        throw FirebaseAuthException(
          code: 'invalid-api-key',
          message:
              'API key Firebase tidak valid. Periksa file google-services.json dan pastikan menggunakan konfigurasi Firebase yang benar.',
        );
      }
      throw FirebaseAuthException(code: 'unknown', message: text);
    }
  }

  Future<UserCredential> login(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      final msg = e.message ?? '';
      if (msg.contains('API key not valid') ||
          msg.contains('invalid-api-key') ||
          msg.contains('invalid API key')) {
        throw FirebaseAuthException(
          code: 'invalid-api-key',
          message:
              'API key Firebase tidak valid. Periksa file google-services.json dan pastikan menggunakan konfigurasi Firebase yang benar.',
        );
      }
      throw FirebaseAuthException(
        code: e.code,
        message: _firebaseErrorMessage(e),
      );
    } catch (e) {
      final text = e.toString();
      if (text.contains('API key not valid') ||
          text.contains('invalid-api-key') ||
          text.contains('invalid API key')) {
        throw FirebaseAuthException(
          code: 'invalid-api-key',
          message:
              'API key Firebase tidak valid. Periksa file google-services.json dan pastikan menggunakan konfigurasi Firebase yang benar.',
        );
      }
      throw FirebaseAuthException(code: 'unknown', message: text);
    }
  }

  String _firebaseErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-api-key':
        return 'API key Firebase tidak valid. Periksa file google-services.json dan pastikan menggunakan konfigurasi Firebase yang benar.';
      case 'user-not-found':
        return 'Akun tidak ditemukan. Silakan periksa email Anda atau daftar terlebih dahulu.';
      case 'wrong-password':
        return 'Password salah. Silakan coba lagi.';
      case 'email-already-in-use':
        return 'Email sudah digunakan. Silakan gunakan email lain atau login.';
      case 'weak-password':
        return 'Password terlalu lemah. Gunakan minimal 6 karakter.';
      case 'invalid-email':
        return 'Format email tidak valid. Periksa kembali alamat email Anda.';
      default:
        return e.message ??
            'Terjadi kesalahan saat berkomunikasi dengan Firebase.';
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}
