import 'package:equatable/equatable.dart';

class SettingsDto extends Equatable {
  /// Settings fields
  final num pageSize;
  final String orderBy;

  ///

  SettingsDto({this.pageSize, this.orderBy});

  static List<SettingsDto> getSettingsDtoList(
      List<SettingsDto> settingsDbList) {
    List<SettingsDto> settingsDtoList = new List<SettingsDto>();

    return settingsDtoList;
  }

  @override
  List<Object> get props => [this.pageSize, this.orderBy];
}
