import '../../../core/constants/app_dimensions.dart';
import '../../discovery/repository/discovery_repository.dart';
import '../model/branch_model.dart';

/// Branch reads for map / reservation / select-table via Discovery.
///
/// Admin `/restaurants/:id/branches` is never called from the customer app.
class BranchRepository {
  BranchRepository(this._discovery);

  final DiscoveryRepository _discovery;

  Future<List<BranchModel>> listBranches(
    String restaurantId, {
    int page = AppDimensions.apiDefaultPage,
    int limit = AppDimensions.apiDefaultLimit,
  }) {
    return _discovery.listBranches(restaurantId, page: page, limit: limit);
  }

  Future<BranchModel?> resolvePrimaryBranch(String restaurantId) {
    return _discovery.resolvePrimaryBranch(restaurantId);
  }
}
