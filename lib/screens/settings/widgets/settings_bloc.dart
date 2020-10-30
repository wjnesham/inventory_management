import 'package:easy_localization/easy_localization.dart';
import 'package:form_bloc/form_bloc.dart';
import 'package:pantryfox/generated/locale_keys.g.dart';
import 'package:pantryfox/helper/userUtils.dart';
import 'package:pantryfox/singleton.dart';

class SettingsFormBloc extends FormBloc<String, String> {
  static final String userName = 'userName';
  static final String pageSize = 'pageSize';
  static final String orderBy = 'orderBy';
  static final String defaultPageSize = "6";
// Backwards localization map.
  static Map<String, dynamic> orderByMap = {
    LocaleKeys.titleString.tr(): LocaleKeys.titleString,
    LocaleKeys.upc.tr(): LocaleKeys.upc,
    LocaleKeys.description.tr(): LocaleKeys.description,
    LocaleKeys.count.tr(): LocaleKeys.count
  };

  final userBloc = TextFieldBloc(
      initialValue: Singleton.instance?.prefs?.getString(userName) ?? "User not found",
      name: userName,
      validators: [FieldBlocValidators.required]);

  final pageSizeBloc = SelectFieldBloc(
    initialValue: Singleton.instance?.prefs?.getString(pageSize) ?? defaultPageSize,
    name: pageSize,
    items: ["6", "12", "18", "24"],
  );

  final orderByBloc = SelectFieldBloc(
      initialValue: orderByMap[Singleton.instance?.prefs?.getString(orderBy)?.tr()] != null
          ? Singleton.instance?.prefs?.getString(orderBy)?.tr()
          : orderByMap.keys.first,
      name: orderBy,
      validators: [FieldBlocValidators.required],
      items: orderByMap.keys.toList());

  void dispose() {
    userBloc.drain();
    pageSizeBloc.drain();
    orderByBloc.drain();
  }

  SettingsFormBloc() {
    addFieldBlocs(fieldBlocs: [userBloc, pageSizeBloc, orderByBloc]);
  }

  @override
  void onSubmitting() async {
    try {
      // Get the fields values:
      String saveUserName = state.textFieldBlocOf(userName).value;
      String savePageSize = state.selectFieldBlocOf(pageSize).value;
      String saveOrderBy = orderByMap[state.selectFieldBlocOf(orderBy).value];

      if (Singleton.instance.prefs == null) {
        printWarning("prefs is still null!");
      }

      /// Set preferences
      await Singleton.instance.prefs?.setString(userName, saveUserName ?? LocaleKeys.userName.tr());
      await Singleton.instance.prefs?.setString(pageSize, savePageSize ?? defaultPageSize);
      await Singleton.instance.prefs?.setString(orderBy, saveOrderBy ?? LocaleKeys.titleString);

      String device = await getDeviceId();
      if (Singleton.instance.prefs.getBool(Singleton.signedInName) == true) {
        await Singleton.instance.firebaseService
            .updateUserData(saveUserName, Singleton.instance?.currentUser?.email, device, savePageSize);
      }

      /// End set
      dispose();

      /// Success
      emitSuccess();
    } catch (e) {
      emitFailure();
    }
  }
}
