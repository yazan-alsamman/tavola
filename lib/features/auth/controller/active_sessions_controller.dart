import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../common/widgets/app_confirm_dialog.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/auth_token_reader.dart';
import '../model/auth_device_session_model.dart';
import '../repository/auth_repository.dart';
import 'auth_session_controller.dart';

class ActiveSessionsController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();

  final RxList<AuthDeviceSessionModel> sessions =
      <AuthDeviceSessionModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxnString errorMessage = RxnString();
  final RxnString revokingSessionId = RxnString();
  final RxBool isLoggingOutAll = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadSessions();
  }

  Future<void> loadSessions() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final String access = await _requireAccessToken();
      final List<AuthDeviceSessionModel> loaded =
          await _authRepository.listSessions(access);
      if (!isClosed) {
        sessions.assignAll(loaded);
      }
    } on ApiException catch (error) {
      if (!isClosed) {
        errorMessage.value = error.message.isNotEmpty
            ? error.message
            : AppStrings.sessionsLoadError;
      }
    } catch (_) {
      if (!isClosed) {
        errorMessage.value = AppStrings.sessionsLoadError;
      }
    } finally {
      if (!isClosed) {
        isLoading.value = false;
      }
    }
  }

  Future<void> revokeSession(AuthDeviceSessionModel session) async {
    if (revokingSessionId.value != null || isLoggingOutAll.value) {
      return;
    }

    if (session.isCurrentSession) {
      final bool confirmed = await AppConfirmDialog.show(
        title: AppStrings.areYouSure,
        message: AppStrings.revokeSessionConfirm,
        icon: Symbols.logout,
        destructiveMessage: true,
      );
      if (!confirmed || isClosed) {
        return;
      }
      if (Get.isRegistered<AuthSessionController>()) {
        await Get.find<AuthSessionController>().logOut();
      }
      return;
    }

    final bool confirmed = await AppConfirmDialog.show(
      title: AppStrings.areYouSure,
      message: AppStrings.revokeSessionConfirm,
      icon: Symbols.devices,
      destructiveMessage: true,
    );
    if (!confirmed || isClosed) {
      return;
    }

    revokingSessionId.value = session.sessionId;
    errorMessage.value = null;
    try {
      final String access = await _requireAccessToken();
      await _authRepository.revokeSession(
        accessToken: access,
        sessionId: session.sessionId,
      );
      if (!isClosed) {
        sessions.removeWhere(
          (AuthDeviceSessionModel item) => item.sessionId == session.sessionId,
        );
      }
    } on ApiException catch (error) {
      if (!isClosed) {
        errorMessage.value = error.message;
      }
    } catch (_) {
      if (!isClosed) {
        errorMessage.value = AppStrings.networkUnexpectedError;
      }
    } finally {
      if (!isClosed) {
        revokingSessionId.value = null;
      }
    }
  }

  Future<void> logOutAllDevices() async {
    if (isLoggingOutAll.value || revokingSessionId.value != null) {
      return;
    }
    final bool confirmed = await AppConfirmDialog.show(
      title: AppStrings.areYouSure,
      message: AppStrings.logOutAllDevices,
      icon: Symbols.logout,
      destructiveMessage: true,
    );
    if (!confirmed || isClosed) {
      return;
    }
    isLoggingOutAll.value = true;
    try {
      if (Get.isRegistered<AuthSessionController>()) {
        await Get.find<AuthSessionController>().logOut(allDevices: true);
      }
    } finally {
      if (!isClosed) {
        isLoggingOutAll.value = false;
      }
    }
  }

  String deviceLabel(AuthDeviceSessionModel session) {
    final String name = session.deviceName.trim();
    if (name.isNotEmpty) {
      return name;
    }
    final String type = session.deviceType.trim();
    if (type.isNotEmpty) {
      return type;
    }
    return AppStrings.unknownDevice;
  }

  Future<String> _requireAccessToken() async {
    if (!Get.isRegistered<AuthTokenReader>()) {
      throw ApiException(message: AppStrings.authRefreshTokenMissing);
    }
    final String? access = await Get.find<AuthTokenReader>().readAccessToken();
    if (access == null || access.trim().isEmpty) {
      throw ApiException(message: AppStrings.authRefreshTokenMissing);
    }
    return access;
  }
}
