// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of cloud_firestore;

/// A QuerySnapshot contains zero or more DocumentSnapshot objects.
class QuerySnapshot {
  final platform.MethodChannelQuerySnapshot _delegate;
  final Firestore _firestore;

  QuerySnapshot._(Map<dynamic, dynamic> data, this._firestore, {platform.MethodChannelQuerySnapshot delegate})
      : _delegate =  delegate ?? platform.MethodChannelQuerySnapshot(
            data, platform.FirestorePlatform.instance);

  /// Gets a list of all the documents included in this snapshot
  List<DocumentSnapshot> get documents =>
      _delegate.documents.map((item) => DocumentSnapshot._(item, _firestore));

  /// An array of the documents that changed since the last snapshot. If this
  /// is the first snapshot, all documents will be in the list as Added changes.
  List<DocumentChange> get documentChanges => _delegate.documentChanges
      .map((item) => DocumentChange._(null, _firestore, delegate: item));

  SnapshotMetadata get metadata => SnapshotMetadata._(_delegate.metadata);
}
