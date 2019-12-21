@TestOn('chrome')
import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:cloud_firestore_web/firestore_web.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase/firestore.dart' as web;
import 'test_common.dart';

const _kPath = "test/document";

class MockWebDocumentSnapshot extends Mock implements web.DocumentSnapshot {}

class MockWebSnapshotMetaData extends Mock implements web.SnapshotMetadata {}

void main() {
  group("$DocumentReferenceWeb()", () {
    final mockWebDocumentReferences = MockDocumentReference();
    DocumentReferenceWeb documentRefernce;
    setUp(() {
      final mockWebFirestore = mockFirestore();
      when(mockWebFirestore.doc(any)).thenReturn(mockWebDocumentReferences);
      documentRefernce = DocumentReferenceWeb(
          mockWebFirestore, FirestorePlatform.instance, _kPath.split("/"));
    });

    test("setData", () {
      documentRefernce.setData({"test": "test"});
      expect(
          verify(mockWebDocumentReferences.set(
                  any, captureThat(isInstanceOf<web.SetOptions>())))
              .captured
              .last
              .merge,
          isFalse);
      documentRefernce.setData({"test": "test"}, merge: true);
      expect(
          verify(mockWebDocumentReferences.set(
                  any, captureThat(isInstanceOf<web.SetOptions>())))
              .captured
              .last
              .merge,
          isTrue);
    });

    test("updateData", () {
      documentRefernce.updateData({"test": "test"});
      verify(mockWebDocumentReferences.update(data: anyNamed("data")));
    });

    test("get", () {
      final mockWebSnapshot = MockWebDocumentSnapshot();
      when(mockWebSnapshot.ref).thenReturn(mockWebDocumentReferences);
      when(mockWebSnapshot.metadata).thenReturn(MockWebSnapshotMetaData());
      when(mockWebDocumentReferences.get())
          .thenAnswer((_) => Future.value(mockWebSnapshot));
      documentRefernce.get();
      verify(mockWebDocumentReferences.get());
    });

    test("delete", () {
      documentRefernce.delete();
      verify(mockWebDocumentReferences.delete());
    });

    test("snapshots", () {
      when(mockWebDocumentReferences.onSnapshot).thenReturn(Stream.empty());
      documentRefernce.snapshots();
      verify(mockWebDocumentReferences.onSnapshot);
    });
  });
}
