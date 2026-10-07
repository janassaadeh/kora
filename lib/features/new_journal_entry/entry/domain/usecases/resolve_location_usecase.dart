import '../repositories/location_repository.dart';

class ResolveLocationUseCase {
  final LocationRepository _repository;

  const ResolveLocationUseCase(this._repository);

  Future<String?> call() => _repository.resolveCurrentCity();
}