import 'dart:io';

import 'package:auth/models/user.dart';
import 'package:auth/utils/app_const.dart';
import 'package:auth/utils/app_response.dart';
import 'package:auth/utils/app_utils.dart';
import 'package:conduit/conduit.dart';

class AppUserController extends ResourceController {
  final ManagedContext managedContext;

  AppUserController(this.managedContext);

  @Operation.get()
  Future<Response> getProfile(
    @Bind.header(HttpHeaders.authorizationHeader) String header,
  ) async {
    try {
      final id = AppUtils.getIdFromHeader(header);
      final user = await managedContext.fetchObjectWithID<User>(id);
      user?.removePropertiesFromBackingMap([
        AppConst.accessToken,
        AppConst.refreshToken,
      ]);
      return AppResponse.ok(
        message: 'Success getting profile',
        body: user?.backing.contents,
      );
    } catch (error) {
      return AppResponse.serverError(
        error,
        message: 'Error getting profile',
      );
    }
  }

  @Operation.post()
  Future<Response> updateProfile(
    @Bind.header(HttpHeaders.authorizationHeader) String header,
    @Bind.body() User user,
  ) async {
    try {
      final id = AppUtils.getIdFromHeader(header);
      final fUser = await managedContext.fetchObjectWithID<User>(id);
      final qUpdateUser = Query<User>(managedContext)
        ..where((x) => x.id).equalTo(id)
        ..values.username = user.username ?? fUser?.username
        ..values.email = user.email ?? fUser?.email;
      await qUpdateUser.updateOne();
      final uUser = await managedContext.fetchObjectWithID<User>(id);
      uUser?.removePropertiesFromBackingMap([
        AppConst.accessToken,
        AppConst.refreshToken,
      ]);
      return AppResponse.ok(
        message: 'Success updated profile',
        body: uUser?.backing.contents,
      );
    } catch (error) {
      return AppResponse.serverError(error, message: 'Error update profile');
    }
  }

  @Operation.put()
  Future<Response> updatePassword(
    @Bind.header(HttpHeaders.authorizationHeader) String header,
    @Bind.query('oldPassword') String oldPassword,
    @Bind.query('newPassword') String newPassword,
  ) async {
    try {
      final id = AppUtils.getIdFromHeader(header);
      final qFindUser = Query<User>(managedContext)
        ..where((table) => table.id).equalTo(id)
        ..returningProperties((x) => [x.salt, x.hashPassword]);
      final findUser = await qFindUser.fetchOne();
      final salt = findUser?.salt ?? '';
      final oldPasswordHash =
          AuthUtility.generatePasswordHash(oldPassword, salt);
      if (oldPasswordHash != findUser?.hashPassword) {
        return AppResponse.badRequest(message: 'Password not correct');
      }
      final newPasswordHash =
          AuthUtility.generatePasswordHash(newPassword, salt);
      final qUpdateUser = Query<User>(managedContext)
        ..where((user) => user.id).equalTo(id)
        ..values.hashPassword = newPasswordHash;
      await qUpdateUser.updateOne();
      return AppResponse.ok(message: 'Success updated password');
    } catch (error) {
      return AppResponse.serverError(error, message: 'Error update password');
    }
  }
}
