// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of cloud_firestore;

typedef Future<dynamic> TransactionHandler(Transaction transaction);

class Transaction {
  @visibleForTesting
  Transaction(this._transactionId, this._firestore)
      : _delegate = platform.Transaction(
            _transactionId, platform.FirestorePlatform.instance);

  platform.Transaction _delegate;
  int _transactionId;
  Firestore _firestore;
  List<Future<dynamic>> _pendingResults = <Future<dynamic>>[];

  Future<void> _finish() => _delegate.finish();

  /// Reads the document referenced by the provided DocumentReference.
  Future<DocumentSnapshot> get(DocumentReference documentReference) {
    final Future<DocumentSnapshot> result = _get(documentReference);
    _pendingResults.add(result);
    return result;
  }

  Future<DocumentSnapshot> _get(DocumentReference documentReference) async {
    final result = await _delegate.get(platform.MethodChannelDocumentReference(
        platform.FirestorePlatform.instance,
        documentReference.path.split("/")));
    if (result != null) {
      return DocumentSnapshot._(result, _firestore);
    } else {
      return null;
    }
  }

  /// Deletes the document referred to by the provided [documentReference].
  ///
  /// Awaiting the returned [Future] is optional and will be done automatically
  /// when the transaction handler completes.
  Future<void> delete(DocumentReference documentReference) {
    final Future<void> result = _delete(documentReference);
    _pendingResults.add(result);
    return result;
  }

  Future<void> _delete(DocumentReference documentReference) async =>
      _delegate.delete(platform.MethodChannelDocumentReference(
          platform.FirestorePlatform.instance,
          documentReference.path.split("/")));

  /// Updates fields in the document referred to by [documentReference].
  /// The update will fail if applied to a document that does not exist.
  ///
  /// Awaiting the returned [Future] is optional and will be done automatically
  /// when the transaction handler completes.
  Future<void> update(
      DocumentReference documentReference, Map<String, dynamic> data) async {
    final Future<void> result = _update(documentReference, data);
    _pendingResults.add(result);
    return result;
  }

  Future<void> _update(DocumentReference documentReference,
          Map<String, dynamic> data) async =>
      _delegate.update(
          platform.MethodChannelDocumentReference(
              platform.FirestorePlatform.instance,
              documentReference.path.split("/")),
          data);

  /// Writes to the document referred to by the provided [DocumentReference].
  /// If the document does not exist yet, it will be created. If you pass
  /// SetOptions, the provided data can be merged into the existing document.
  ///
  /// Awaiting the returned [Future] is optional and will be done automatically
  /// when the transaction handler completes.
  Future<void> set(
      DocumentReference documentReference, Map<String, dynamic> data) {
    final Future<void> result = _set(documentReference, data);
    _pendingResults.add(result);
    return result;
  }

  Future<void> _set(DocumentReference documentReference,
          Map<String, dynamic> data) async =>
      _delegate.set(
          platform.MethodChannelDocumentReference(
              platform.FirestorePlatform.instance,
              documentReference.path.split("/")),
          data);
}
