// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of cloud_firestore;

/// A DocumentSnapshot contains data read from a document in your Firestore
/// database.
///
/// The data can be extracted with the data property or by using subscript
/// syntax to access a specific field.
class DocumentSnapshot {
  platform.DocumentSnapshot _deletage;
  Firestore _firestore;
  DocumentSnapshot._(this._deletage, this._firestore);


  /// The reference that produced this snapshot
  DocumentReference get reference => _firestore.document(_deletage.reference.path);

  /// Contains all the data of this snapshot
  Map<String, dynamic> get data => _deletage.data;

  /// Metadata about this snapshot concerning its source and if it has local
  /// modifications.
  SnapshotMetadata get metadata=> SnapshotMetadata._(_deletage.metadata);

  /// Reads individual values from the snapshot
  dynamic operator [](String key) => data[key];

  /// Returns the ID of the snapshot's document
  String get documentID => _deletage.documentID;

  /// Returns `true` if the document exists.
  bool get exists => data != null;
}

Map<String, dynamic> _asStringKeyedMap(Map<dynamic, dynamic> map) {
  if (map == null) return null;
  if (map is Map<String, dynamic>) {
    return map;
  } else {
    return Map<String, dynamic>.from(map);
  }
}
