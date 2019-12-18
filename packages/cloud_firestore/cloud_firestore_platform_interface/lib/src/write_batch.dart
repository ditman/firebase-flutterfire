// Copyright 2018, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of cloud_firestore_platform_interface;

/// A [WriteBatch] is a series of write operations to be performed as one unit.
///
/// Operations done on a [WriteBatch] do not take effect until you [commit].
///
/// Once committed, no further operations can be performed on the [WriteBatch],
/// nor can it be committed again.
class WriteBatch extends WriteBatchPlatform {
  WriteBatch(this._firestore)
      : _handle = MethodChannelFirestore.channel.invokeMethod<dynamic>(
            'WriteBatch#create', <String, dynamic>{'app': _firestore.appName()}),
        super._();

  final FirestorePlatform _firestore;
  Future<dynamic> _handle;
  final List<Future<dynamic>> _actions = <Future<dynamic>>[];

  @override
  Future<void> commit() async {
    if (!_committed) {
      _committed = true;
      await Future.wait<dynamic>(_actions);
      await MethodChannelFirestore.channel.invokeMethod<void>(
          'WriteBatch#commit', <String, dynamic>{'handle': await _handle});
    } else {
      throw StateError("This batch has already been committed.");
    }
  }

  @override
  void delete(DocumentReference document) {
    if (!_committed) {
      _handle.then((dynamic handle) {
        _actions.add(
          MethodChannelFirestore.channel.invokeMethod<void>(
            'WriteBatch#delete',
            <String, dynamic>{
              'app': _firestore.appName(),
              'handle': handle,
              'path': document.path,
            },
          ),
        );
      });
    } else {
      throw StateError(
          "This batch has been committed and can no longer be changed.");
    }
  }

  @override
  void setData(DocumentReference document, Map<String, dynamic> data,
      {bool merge = false}) {
    if (!_committed) {
      _handle.then((dynamic handle) {
        _actions.add(
          MethodChannelFirestore.channel.invokeMethod<void>(
            'WriteBatch#setData',
            <String, dynamic>{
              'app': _firestore.appName(),
              'handle': handle,
              'path': document.path,
              'data': data,
              'options': <String, bool>{'merge': merge},
            },
          ),
        );
      });
    } else {
      throw StateError(
          "This batch has been committed and can no longer be changed.");
    }
  }

  @override
  void updateData(DocumentReference document, Map<String, dynamic> data) {
    if (!_committed) {
      _handle.then((dynamic handle) {
        _actions.add(
          MethodChannelFirestore.channel.invokeMethod<void>(
            'WriteBatch#updateData',
            <String, dynamic>{
              'app': _firestore.appName(),
              'handle': handle,
              'path': document.path,
              'data': data,
            },
          ),
        );
      });
    } else {
      throw StateError(
          "This batch has been committed and can no longer be changed.");
    }
  }
}
