import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:firebase/firestore.dart' as web;

class QueryWeb implements Query {
  final web.CollectionReference webCollection;
  final web.Query webQuery;
  final FirestorePlatform _firestore;
  final bool _isCollectionGroup;
  final String _path;

  QueryWeb(this._firestore,this._path, {bool isCollectionGroup, this.webCollection, this.webQuery}): this._isCollectionGroup = isCollectionGroup ?? false;

  @override
  Stream<QuerySnapshot> snapshots({bool includeMetadataChanges = false}) {
    assert(webQuery != null || webCollection != null);
    Stream<web.QuerySnapshot> webSnapshots;
    if (webQuery != null) {
      webSnapshots = webQuery.onSnapshot;
    } else if (webCollection != null) {
      webSnapshots = webCollection.onSnapshot;
    }
    return webSnapshots.map(_webQuerySnapshotToQuerySnapshot);
  }

  @override
  Future<QuerySnapshot> getDocuments(
      {Source source = Source.serverAndCache}) async {
    assert(webQuery != null || webCollection != null);
    web.QuerySnapshot webDocuments;
    if (webQuery != null) {
      webDocuments = await webQuery.get();
    } else if (webCollection != null) {
      webDocuments = await webCollection.get();
    }

    return _webQuerySnapshotToQuerySnapshot(webDocuments);
  }

  @override
  Map<String, dynamic> buildArguments() {
    return null;
  }

  @override
  Query endAt(List values) => QueryWeb(
      this._firestore,
      this._path,
      webQuery: webQuery ?? webQuery.endAt(fieldValues: values),
      webCollection: webCollection ?? webCollection.endAt(fieldValues: values)
  );

  @override
  Query endAtDocument(DocumentSnapshot documentSnapshot) =>
    QueryWeb(
      this._firestore,
        this._path,
      webQuery: webQuery ?? webQuery.endAt(snapshot: ),
      webCollection: webCollection ?? webCollection.endAt(snapshot: )
    );

  @override
  Query endBefore(List values) =>
      QueryWeb(
          this._firestore,
          this._path,
          webQuery: webQuery ?? webQuery.endBefore(fieldValues: values),
          webCollection: webCollection ?? webCollection.endBefore(fieldValues: values)
      );

  @override
  Query endBeforeDocument(DocumentSnapshot documentSnapshot) =>
      QueryWeb(
          this._firestore,
          this._path,
          webQuery: webQuery ?? webQuery.endAt(),
          webCollection: webCollection ?? webCollection.endAt()
      );

  @override
  FirestorePlatform get firestore => _firestore;

  @override
  bool get isCollectionGroup => _isCollectionGroup;

  @override
  Query limit(int length) =>
      QueryWeb(
          this._firestore,
          this._path,
          webQuery: webQuery ?? webQuery.limit(length),
          webCollection: webCollection ?? webCollection.limit(length)
      );

  @override
  Query orderBy(field, {bool descending = false}) =>
      QueryWeb(
          this._firestore,
        this._path,
          webQuery: webQuery ?? webQuery.orderBy(field, descending ? "desc" : "asc"),
          webCollection: webCollection ?? webCollection.orderBy(field, descending ? "desc" : "asc"),
      );

  @override
  Map<String, dynamic> get parameters => null;

  @override
  String get path => this._path;

  @override
  // TODO: implement pathComponents
  List<String> get pathComponents => this._path.split("/");

  @override
  CollectionReference reference() => firestore.collection(_path);

  @override
  Query startAfter(List values) => QueryWeb(
    this._firestore,
    this._path,
    webQuery: webQuery ?? webQuery.startAfter(fieldValues: values),
    webCollection: webCollection ?? webCollection.startAfter(fieldValues: values),
  );

  @override
  Query startAfterDocument(DocumentSnapshot documentSnapshot) =>
      QueryWeb(
        this._firestore,
        this._path,
        webQuery: webQuery ?? webQuery.startAfter(snapshot: ),
        webCollection: webCollection ?? webCollection.startAfter(snapshot: ),
      );

  @override
  Query startAt(List values) => QueryWeb(
    this._firestore,
    this._path,
    webQuery: webQuery ?? webQuery.startAt(fieldValues: values),
    webCollection: webCollection ?? webCollection.startAt(fieldValues: values),
  );

  @override
  Query startAtDocument(DocumentSnapshot documentSnapshot) =>
      QueryWeb(
        this._firestore,
        this._path,
        webQuery: webQuery ?? webQuery.startAt(snapshot: ),
        webCollection: webCollection ?? webCollection.startAt(snapshot: ),
      );

  @override
  Query where(field,
      {isEqualTo,
      isLessThan,
      isLessThanOrEqualTo,
      isGreaterThan,
      isGreaterThanOrEqualTo,
      arrayContains,
      List arrayContainsAny,
      List whereIn,
      bool isNull}) {
    assert(field is String || field is FieldPath,
    'Supported [field] types are [String] and [FieldPath].');
    assert(webQuery != null || webCollection != null);
    web.Query query;
    if (webQuery != null) {
      query = webQuery;
    } else if (webCollection != null) {
      query = webCollection;
    }
    if(isEqualTo != null) {
      query = query.where(field, "==", isEqualTo);
    }
    if(isLessThan != null) {
      query = query.where(field, "<", isLessThan);
    }
    if(isLessThanOrEqualTo != null) {
      query = query.where(field, "<=", isLessThanOrEqualTo);
    }
    if(isGreaterThan != null) {
      query = query.where(field, ">", isGreaterThan);
    }
    if(isGreaterThanOrEqualTo != null) {
      query = query.where(field, ">=", isGreaterThanOrEqualTo);
    }
    if(arrayContains != null) {
      query = query.where(field, "array-contains", arrayContains);
    }
    if(arrayContainsAny != null) {
      assert(arrayContainsAny.length <= 10, "array contains can have maximum of 10 items");
      query = query.where(field, "array-contains-any", arrayContainsAny);
    }
    if(whereIn != null) {
      assert(whereIn.length <= 10, "array contains can have maximum of 10 items");
      query = query.where(field, "in", whereIn);
    }
    if(isNull != null ) {
      assert(
      isNull,
      'isNull can only be set to true. '
          'Use isEqualTo to filter on non-null values.');
      query = query.where(field, "==", null);
    }
  }

  @override
  Query copyWithParameters(Map<String, dynamic> parameters) => this;

  QuerySnapshot _webQuerySnapshotToQuerySnapshot(web.QuerySnapshot webSnapshot) =>
      QuerySnapshot(
          webSnapshot.docs.map(_webDocumentSnapshotToDocumentSnapshot),
          webSnapshot.docChanges().map(_webChangeToChange),
          _webMetadataToMetada(webSnapshot.metadata));

  DocumentChange _webChangeToChange(web.DocumentChange webChange) =>
      DocumentChange(
          DocumentChangeType.values.firstWhere((DocumentChangeType type) {
        return type.toString() == webChange.type.toLowerCase();
      }), webChange.oldIndex, webChange.newIndex,
          _webDocumentSnapshotToDocumentSnapshot(webChange.doc));

  DocumentSnapshot _webDocumentSnapshotToDocumentSnapshot(web.DocumentSnapshot webSnapshot) =>
      DocumentSnapshot(
          webSnapshot.ref.path,
          webSnapshot.data(),
          SnapshotMetadata(webSnapshot.metadata.hasPendingWrites,
              webSnapshot.metadata.fromCache),
          this._firestore);

  SnapshotMetadata _webMetadataToMetada(web.SnapshotMetadata webMetadata) =>
      SnapshotMetadata(
        webMetadata.hasPendingWrites,
        webMetadata.fromCache
      );
}
