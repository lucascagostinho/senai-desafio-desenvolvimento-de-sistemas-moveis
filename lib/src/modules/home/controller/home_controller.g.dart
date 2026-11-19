// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$HomeController on HomeControllerBase, Store {
  Computed<bool>? _$isLoadingComputed;

  @override
  bool get isLoading => (_$isLoadingComputed ??= Computed<bool>(
    () => super.isLoading,
    name: 'HomeControllerBase.isLoading',
  )).value;

  late final _$statusAtom = Atom(
    name: 'HomeControllerBase.status',
    context: context,
  );

  @override
  HomeStatus get status {
    _$statusAtom.reportRead();
    return super.status;
  }

  @override
  set status(HomeStatus value) {
    _$statusAtom.reportWrite(value, super.status, () {
      super.status = value;
    });
  }

  late final _$lastAddressAtom = Atom(
    name: 'HomeControllerBase.lastAddress',
    context: context,
  );

  @override
  AddressModel? get lastAddress {
    _$lastAddressAtom.reportRead();
    return super.lastAddress;
  }

  @override
  set lastAddress(AddressModel? value) {
    _$lastAddressAtom.reportWrite(value, super.lastAddress, () {
      super.lastAddress = value;
    });
  }

  late final _$resultsAtom = Atom(
    name: 'HomeControllerBase.results',
    context: context,
  );

  @override
  ObservableList<AddressModel> get results {
    _$resultsAtom.reportRead();
    return super.results;
  }

  @override
  set results(ObservableList<AddressModel> value) {
    _$resultsAtom.reportWrite(value, super.results, () {
      super.results = value;
    });
  }

  late final _$recentAtom = Atom(
    name: 'HomeControllerBase.recent',
    context: context,
  );

  @override
  ObservableList<AddressModel> get recent {
    _$recentAtom.reportRead();
    return super.recent;
  }

  @override
  set recent(ObservableList<AddressModel> value) {
    _$recentAtom.reportWrite(value, super.recent, () {
      super.recent = value;
    });
  }

  late final _$errorMessageAtom = Atom(
    name: 'HomeControllerBase.errorMessage',
    context: context,
  );

  @override
  String? get errorMessage {
    _$errorMessageAtom.reportRead();
    return super.errorMessage;
  }

  @override
  set errorMessage(String? value) {
    _$errorMessageAtom.reportWrite(value, super.errorMessage, () {
      super.errorMessage = value;
    });
  }

  late final _$isRoutingAtom = Atom(
    name: 'HomeControllerBase.isRouting',
    context: context,
  );

  @override
  bool get isRouting {
    _$isRoutingAtom.reportRead();
    return super.isRouting;
  }

  @override
  set isRouting(bool value) {
    _$isRoutingAtom.reportWrite(value, super.isRouting, () {
      super.isRouting = value;
    });
  }

  late final _$loadRecentAsyncAction = AsyncAction(
    'HomeControllerBase.loadRecent',
    context: context,
  );

  @override
  Future<void> loadRecent() {
    return _$loadRecentAsyncAction.run(() => super.loadRecent());
  }

  late final _$searchByCepAsyncAction = AsyncAction(
    'HomeControllerBase.searchByCep',
    context: context,
  );

  @override
  Future<void> searchByCep(String cep) {
    return _$searchByCepAsyncAction.run(() => super.searchByCep(cep));
  }

  late final _$searchByAddressAsyncAction = AsyncAction(
    'HomeControllerBase.searchByAddress',
    context: context,
  );

  @override
  Future<void> searchByAddress({
    required String uf,
    required String city,
    required String street,
  }) {
    return _$searchByAddressAsyncAction.run(
      () => super.searchByAddress(uf: uf, city: city, street: street),
    );
  }

  late final _$selectAsyncAction = AsyncAction(
    'HomeControllerBase.select',
    context: context,
  );

  @override
  Future<void> select(AddressModel address) {
    return _$selectAsyncAction.run(() => super.select(address));
  }

  late final _$traceRouteAsyncAction = AsyncAction(
    'HomeControllerBase.traceRoute',
    context: context,
  );

  @override
  Future<void> traceRoute() {
    return _$traceRouteAsyncAction.run(() => super.traceRoute());
  }

  late final _$HomeControllerBaseActionController = ActionController(
    name: 'HomeControllerBase',
    context: context,
  );

  @override
  void newSearch() {
    final _$actionInfo = _$HomeControllerBaseActionController.startAction(
      name: 'HomeControllerBase.newSearch',
    );
    try {
      return super.newSearch();
    } finally {
      _$HomeControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearError() {
    final _$actionInfo = _$HomeControllerBaseActionController.startAction(
      name: 'HomeControllerBase.clearError',
    );
    try {
      return super.clearError();
    } finally {
      _$HomeControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
status: ${status},
lastAddress: ${lastAddress},
results: ${results},
recent: ${recent},
errorMessage: ${errorMessage},
isRouting: ${isRouting},
isLoading: ${isLoading}
    ''';
  }
}
