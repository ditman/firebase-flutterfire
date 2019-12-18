// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of cloud_firestore_platform_interface;

/// Represents a query over the data at a particular location.
abstract class Query {
  Query(
      {@required this.firestore,
      @required List<String> pathComponents,
      bool isCollectionGroup = false,
      Map<String, dynamic> parameters})
      : pathComponents = pathComponents,
        isCollectionGroup = isCollectionGroup,
        parameters = parameters ??
            Map<String, dynamic>.unmodifiable(<String, dynamic>{
              'where': List<List<dynamic>>.unmodifiable(<List<dynamic>>[]),
              'orderBy': List<List<dynamic>>.unmodifiable(<List<dynamic>>[]),
            }),
        assert(firestore != null),
        assert(pathComponents != null);

  /// The Firestore instance associated with this query
  final FirestorePlatform firestore;

  final List<String> pathComponents;
  final Map<String, dynamic> parameters;
  final bool isCollectionGroup;

  String get path => pathComponents.join('/');

  Query _copyWithParameters(Map<String, dynamic> parameters) {
    throw UnimplementedError("copyWithParameters() is not implemented");
  }

  Map<String, dynamic> buildArguments() {
    return Map<String, dynamic>.from(parameters)
      ..addAll(<String, dynamic>{
        'path': path,
      });
  }

  /// Notifies of query results at this location
  Stream<QuerySnapshot> snapshots({bool includeMetadataChanges = false}) {
    throw UnimplementedError("snapshots() is not implemented");
  }

  /// Fetch the documents for this query
  Future<QuerySnapshot> getDocuments(
      {Source source = Source.serverAndCache}) async {
    throw UnimplementedError("getDocuments() is not implemented");
  }

  /// Obtains a CollectionReference corresponding to this query's location.
  CollectionReference reference() =>
      firestore.collection(pathComponents.join("/"));

  /// Creates and returns a new [Query] with additional filter on specified
  /// [field]. [field] refers to a field in a document.
  ///
  /// The [field] may be a [String] consisting of a single field name
  /// (referring to a top level field in the document),
  /// or a series of field names separated by dots '.'
  /// (referring to a nested field in the document).
  /// Alternatively, the [field] can also be a [FieldPath].
  ///
  /// Only documents satisfying provided condition are included in the result
  /// set.
  Query where(
    dynamic field, {
    dynamic isEqualTo,
    dynamic isLessThan,
    dynamic isLessThanOrEqualTo,
    dynamic isGreaterThan,
    dynamic isGreaterThanOrEqualTo,
    dynamic arrayContains,
    List<dynamic> arrayContainsAny,
    List<dynamic> whereIn,
    bool isNull,
  }) {
    assert(field is String || field is FieldPath,
        'Supported [field] types are [String] and [FieldPath].');

    final ListEquality<dynamic> equality = const ListEquality<dynamic>();
    final List<List<dynamic>> conditions =
        List<List<dynamic>>.from(parameters['where']);

    void addCondition(dynamic field, String operator, dynamic value) {
      final List<dynamic> condition = <dynamic>[field, operator, value];
      assert(
          conditions
              .where((List<dynamic> item) => equality.equals(condition, item))
              .isEmpty,
          'Condition $condition already exists in this query.');
      conditions.add(condition);
    }

    if (isEqualTo != null) addCondition(field, '==', isEqualTo);
    if (isLessThan != null) addCondition(field, '<', isLessThan);
    if (isLessThanOrEqualTo != null)
      addCondition(field, '<=', isLessThanOrEqualTo);
    if (isGreaterThan != null) addCondition(field, '>', isGreaterThan);
    if (isGreaterThanOrEqualTo != null)
      addCondition(field, '>=', isGreaterThanOrEqualTo);
    if (arrayContains != null)
      addCondition(field, 'array-contains', arrayContains);
    if (arrayContainsAny != null)
      addCondition(field, 'array-contains-any', arrayContainsAny);
    if (whereIn != null) addCondition(field, 'in', whereIn);
    if (isNull != null) {
      assert(
          isNull,
          'isNull can only be set to true. '
          'Use isEqualTo to filter on non-null values.');
      addCondition(field, '==', null);
    }

    return _copyWithParameters(<String, dynamic>{'where': conditions});
  }

  /// Creates and returns a new [Query] that's additionally sorted by the specified
  /// [field].
  /// The field may be a [String] representing a single field name or a [FieldPath].
  ///
  /// After a [FieldPath.documentId] order by call, you cannot add any more [orderBy]
  /// calls.
  /// Furthermore, you may not use [orderBy] on the [FieldPath.documentId] [field] when
  /// using [startAfterDocument], [startAtDocument], [endAfterDocument],
  /// or [endAtDocument] because the order by clause on the document id
  /// is added by these methods implicitly.
  Query orderBy(dynamic field, {bool descending = false}) {
    assert(field != null && descending != null);
    assert(field is String || field is FieldPath,
        'Supported [field] types are [String] and [FieldPath].');

    final List<List<dynamic>> orders =
        List<List<dynamic>>.from(parameters['orderBy']);

    final List<dynamic> order = <dynamic>[field, descending];
    assert(orders.where((List<dynamic> item) => field == item[0]).isEmpty,
        'OrderBy $field already exists in this query');

    assert(() {
      if (field == FieldPath.documentId) {
        return !(parameters.containsKey('startAfterDocument') ||
            parameters.containsKey('startAtDocument') ||
            parameters.containsKey('endAfterDocument') ||
            parameters.containsKey('endAtDocument'));
      }
      return true;
    }(),
        '{start/end}{At/After/Before}Document order by document id themselves. '
        'Hence, you may not use an order by [FieldPath.documentId] when using any of these methods for a query.');

    orders.add(order);
    return _copyWithParameters(<String, dynamic>{'orderBy': orders});
  }

  /// Creates and returns a new [Query] that starts after the provided document
  /// (exclusive). The starting position is relative to the order of the query.
  /// The document must contain all of the fields provided in the orderBy of
  /// this query.
  ///
  /// Cannot be used in combination with [startAtDocument], [startAt], or
  /// [startAfter], but can be used in combination with [endAt],
  /// [endBefore], [endAtDocument] and [endBeforeDocument].
  ///
  /// See also:
  ///
  ///  * [endAfterDocument] for a query that ends after a document.
  ///  * [startAtDocument] for a query that starts at a document.
  ///  * [endAtDocument] for a query that ends at a document.
  Query startAfterDocument(DocumentSnapshot documentSnapshot) {
    assert(documentSnapshot != null);
    assert(!parameters.containsKey('startAfter'));
    assert(!parameters.containsKey('startAt'));
    assert(!parameters.containsKey('startAfterDocument'));
    assert(!parameters.containsKey('startAtDocument'));
    assert(
        List<List<dynamic>>.from(parameters['orderBy'])
            .where((List<dynamic> item) => item[0] == FieldPath.documentId)
            .isEmpty,
        '[startAfterDocument] orders by document id itself. '
        'Hence, you may not use an order by [FieldPath.documentId] when using [startAfterDocument].');
    return _copyWithParameters(<String, dynamic>{
      'startAfterDocument': <String, dynamic>{
        'id': documentSnapshot.documentID,
        'path': documentSnapshot.reference.path,
        'data': documentSnapshot.data
      }
    });
  }

  /// Creates and returns a new [Query] that starts at the provided document
  /// (inclusive). The starting position is relative to the order of the query.
  /// The document must contain all of the fields provided in the orderBy of
  /// this query.
  ///
  /// Cannot be used in combination with [startAfterDocument], [startAfter], or
  /// [startAt], but can be used in combination with [endAt],
  /// [endBefore], [endAtDocument] and [endBeforeDocument].
  ///
  /// See also:
  ///
  ///  * [startAfterDocument] for a query that starts after a document.
  ///  * [endAtDocument] for a query that ends at a document.
  ///  * [endBeforeDocument] for a query that ends before a document.
  Query startAtDocument(DocumentSnapshot documentSnapshot) {
    assert(documentSnapshot != null);
    assert(!parameters.containsKey('startAfter'));
    assert(!parameters.containsKey('startAt'));
    assert(!parameters.containsKey('startAfterDocument'));
    assert(!parameters.containsKey('startAtDocument'));
    assert(
        List<List<dynamic>>.from(parameters['orderBy'])
            .where((List<dynamic> item) => item[0] == FieldPath.documentId)
            .isEmpty,
        '[startAtDocument] orders by document id itself. '
        'Hence, you may not use an order by [FieldPath.documentId] when using [startAtDocument].');
    return _copyWithParameters(<String, dynamic>{
      'startAtDocument': <String, dynamic>{
        'id': documentSnapshot.documentID,
        'path': documentSnapshot.reference.path,
        'data': documentSnapshot.data
      },
    });
  }

  /// Takes a list of [values], creates and returns a new [Query] that starts
  /// after the provided fields relative to the order of the query.
  ///
  /// The [values] must be in order of [orderBy] filters.
  ///
  /// Cannot be used in combination with [startAt], [startAfterDocument], or
  /// [startAtDocument], but can be used in combination with [endAt],
  /// [endBefore], [endAtDocument] and [endBeforeDocument].
  Query startAfter(List<dynamic> values) {
    assert(values != null);
    assert(!parameters.containsKey('startAfter'));
    assert(!parameters.containsKey('startAt'));
    assert(!parameters.containsKey('startAfterDocument'));
    assert(!parameters.containsKey('startAtDocument'));
    return _copyWithParameters(<String, dynamic>{'startAfter': values});
  }

  /// Takes a list of [values], creates and returns a new [Query] that starts at
  /// the provided fields relative to the order of the query.
  ///
  /// The [values] must be in order of [orderBy] filters.
  ///
  /// Cannot be used in combination with [startAfter], [startAfterDocument],
  /// or [startAtDocument], but can be used in combination with [endAt],
  /// [endBefore], [endAtDocument] and [endBeforeDocument].
  Query startAt(List<dynamic> values) {
    assert(values != null);
    assert(!parameters.containsKey('startAfter'));
    assert(!parameters.containsKey('startAt'));
    assert(!parameters.containsKey('startAfterDocument'));
    assert(!parameters.containsKey('startAtDocument'));
    return _copyWithParameters(<String, dynamic>{'startAt': values});
  }

  /// Creates and returns a new [Query] that ends at the provided document
  /// (inclusive). The end position is relative to the order of the query.
  /// The document must contain all of the fields provided in the orderBy of
  /// this query.
  ///
  /// Cannot be used in combination with [endBefore], [endBeforeDocument], or
  /// [endAt], but can be used in combination with [startAt],
  /// [startAfter], [startAtDocument] and [startAfterDocument].
  ///
  /// See also:
  ///
  ///  * [startAfterDocument] for a query that starts after a document.
  ///  * [startAtDocument] for a query that starts at a document.
  ///  * [endBeforeDocument] for a query that ends before a document.
  Query endAtDocument(DocumentSnapshot documentSnapshot) {
    assert(documentSnapshot != null);
    assert(!parameters.containsKey('endBefore'));
    assert(!parameters.containsKey('endAt'));
    assert(!parameters.containsKey('endBeforeDocument'));
    assert(!parameters.containsKey('endAtDocument'));
    assert(
        List<List<dynamic>>.from(parameters['orderBy'])
            .where((List<dynamic> item) => item[0] == FieldPath.documentId)
            .isEmpty,
        '[endAtDocument] orders by document id itself. '
        'Hence, you may not use an order by [FieldPath.documentId] when using [endAtDocument].');
    return _copyWithParameters(<String, dynamic>{
      'endAtDocument': <String, dynamic>{
        'id': documentSnapshot.documentID,
        'path': documentSnapshot.reference.path,
        'data': documentSnapshot.data
      },
    });
  }

  /// Takes a list of [values], creates and returns a new [Query] that ends at the
  /// provided fields relative to the order of the query.
  ///
  /// The [values] must be in order of [orderBy] filters.
  ///
  /// Cannot be used in combination with [endBefore], [endBeforeDocument], or
  /// [endAtDocument], but can be used in combination with [startAt],
  /// [startAfter], [startAtDocument] and [startAfterDocument].
  Query endAt(List<dynamic> values) {
    assert(values != null);
    assert(!parameters.containsKey('endBefore'));
    assert(!parameters.containsKey('endAt'));
    assert(!parameters.containsKey('endBeforeDocument'));
    assert(!parameters.containsKey('endAtDocument'));
    return _copyWithParameters(<String, dynamic>{'endAt': values});
  }

  /// Creates and returns a new [Query] that ends before the provided document
  /// (exclusive). The end position is relative to the order of the query.
  /// The document must contain all of the fields provided in the orderBy of
  /// this query.
  ///
  /// Cannot be used in combination with [endAt], [endBefore], or
  /// [endAtDocument], but can be used in combination with [startAt],
  /// [startAfter], [startAtDocument] and [startAfterDocument].
  ///
  /// See also:
  ///
  ///  * [startAfterDocument] for a query that starts after document.
  ///  * [startAtDocument] for a query that starts at a document.
  ///  * [endAtDocument] for a query that ends at a document.
  Query endBeforeDocument(DocumentSnapshot documentSnapshot) {
    assert(documentSnapshot != null);
    assert(!parameters.containsKey('endBefore'));
    assert(!parameters.containsKey('endAt'));
    assert(!parameters.containsKey('endBeforeDocument'));
    assert(!parameters.containsKey('endAtDocument'));
    assert(
        List<List<dynamic>>.from(parameters['orderBy'])
            .where((List<dynamic> item) => item[0] == FieldPath.documentId)
            .isEmpty,
        '[endBeforeDocument] orders by document id itself. '
        'Hence, you may not use an order by [FieldPath.documentId] when using [endBeforeDocument].');
    return _copyWithParameters(<String, dynamic>{
      'endBeforeDocument': <String, dynamic>{
        'id': documentSnapshot.documentID,
        'path': documentSnapshot.reference.path,
        'data': documentSnapshot.data,
      },
    });
  }

  /// Takes a list of [values], creates and returns a new [Query] that ends before
  /// the provided fields relative to the order of the query.
  ///
  /// The [values] must be in order of [orderBy] filters.
  ///
  /// Cannot be used in combination with [endAt], [endBeforeDocument], or
  /// [endBeforeDocument], but can be used in combination with [startAt],
  /// [startAfter], [startAtDocument] and [startAfterDocument].
  Query endBefore(List<dynamic> values) {
    assert(values != null);
    assert(!parameters.containsKey('endBefore'));
    assert(!parameters.containsKey('endAt'));
    assert(!parameters.containsKey('endBeforeDocument'));
    assert(!parameters.containsKey('endAtDocument'));
    return _copyWithParameters(<String, dynamic>{'endBefore': values});
  }

  /// Creates and returns a new Query that's additionally limited to only return up
  /// to the specified number of documents.
  Query limit(int length) {
    assert(!parameters.containsKey('limit'));
    return _copyWithParameters(<String, dynamic>{'limit': length});
  }
}
