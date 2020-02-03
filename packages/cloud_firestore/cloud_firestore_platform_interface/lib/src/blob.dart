import 'dart:typed_data';
import 'dart:ui';

import 'package:collection/collection.dart';

/// Represents binary data stored in [Uint8List].
class Blob {
  /// Create a blob.
  const Blob(this.bytes);

  /// The bytes that are contained in this blob.
  final Uint8List bytes;

  @override
  bool operator ==(dynamic other) =>
      other is Blob &&
      const DeepCollectionEquality().equals(other.bytes, bytes);

  @override
  int get hashCode => hashList(bytes);
}
