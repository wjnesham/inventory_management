import 'package:equatable/equatable.dart';
import 'package:jaguar_orm/jaguar_orm.dart';

/// This is the UPC object to save in the database. We don't want to store everything from the json (See upc.dart).
/// Just enough to find the record and display details.
class UpcDb extends Equatable {
  @PrimaryKey()
  String code; //upc number
  @Column(isNullable: true)
  num total;
  @Column(isNullable: true)
  String title;
  @Column(isNullable: true)
  String description;
  @Column(isNullable: true)
  String imageLink;

  @Column(isNullable: true)
  String cupboard;
  @Column(isNullable: true)
  String brand;
  @Column(isNullable: true)
  String model;
  @Column(isNullable: true)
  String price;
  @Column(isNullable: true)
  String weight;
  @Column(isNullable: true)
  bool selected = false;

  Map histories;

  UpcDb(
      {this.code,
      this.total = 0,
      this.title = "",
      this.description = "",
      this.imageLink = "",
      this.cupboard = "",
      this.brand = "",
      this.model = "",
      this.price = "",
      this.weight = "",
      this.selected});

  static const String codeName = 'code';
  static const String totalName = 'total';
  static const String titleName = 'title';
  static const String descriptionName = 'description';
  static const String imageLinkName = 'imageLink';

  //new
  static const String cupboardName = 'cupboard';
  static const String brandName = 'brand';
  static const String modelName = 'model';
  static const String priceName = 'price';
  static const String weightName = 'weight';
  static const String selectedName = 'selected';
  static const String historiesName = 'histories';

  Map<String, dynamic> toJson() => {
        codeName: this.code,
        totalName: this.total,
        titleName: this.title,
        descriptionName: this.description,
        imageLinkName: this.imageLink,
        cupboardName: this.cupboard,
        brandName: this.brand,
        modelName: this.model,
        priceName: this.price,
        weightName: this.weight,
        selectedName: this.selected,
      };

  factory UpcDb.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      throw FormatException("Null JSON provided to Upc");
    }

    if (json[0] is num) {
      //TODO: Check if ID is correct ID.
      print('Creating UpcDb from database.');
    }

    // Change this if Json is changed from the expected.
    return UpcDb(
      code: json[codeName] == null ? "" : json[codeName],
      total: int.tryParse(json[totalName] ?? "0") ?? 0,
      title: json[titleName] ?? "",
      description: json[descriptionName] ?? "",
      imageLink: json[imageLinkName] ?? "",
      cupboard: json[cupboardName] ?? "Default Cupboard Name",
      brand: json[brandName] ?? "",
      model: json[modelName] ?? "",
      price: json[priceName] ?? "",
      weight: json[weightName] ?? "",
      selected: false,
    );
  }

  ///When getting an object from the database using findOne() or findAll(),
  ///those methods return the objects in a Map.
  ///This method extracts the object from the Map and returns an instance of that type.
  static UpcDb getUpcDbFromMap(Map upcMap) {
    if (upcMap == null) {
      print("UpcDb getUpcDbFromMap - map is null");
      return null;
    }
    UpcDb upcDb = new UpcDb();
    upcDb.code = upcMap[UpcDb.codeName];
    upcDb.imageLink = upcMap[UpcDb.imageLinkName];
    upcDb.title = upcMap[UpcDb.titleName];
    upcDb.total = int.tryParse(upcMap[UpcDb.totalName] ?? "1") ?? 1;
    upcDb.description = upcMap[UpcDb.descriptionName] ?? "";

    upcDb.cupboard = upcMap[UpcDb.cupboardName];
    upcDb.brand = upcMap[UpcDb.brandName];
    upcDb.model = upcMap[UpcDb.modelName];
    upcDb.price = upcMap[UpcDb.priceName];
    upcDb.weight = upcMap[UpcDb.weightName];
    var select = upcMap[UpcDb.selectedName];
    if (select is int) {
      upcDb.selected = (select == 1) ? true : false;
    } else {
      upcDb.selected = select ?? false;
    }

    return upcDb;
  }

  @override
  List<Object> get props => [this.code];
}
