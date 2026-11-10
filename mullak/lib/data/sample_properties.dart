import '../models/property.dart';

/// TEMPORARY sample data, used until Firebase is connected (sprint 5).
///
/// The first three properties are the ones from our Figma designs.
/// The others were added so the filters and the compare page (up to 4)
/// have enough data to test with.
/// One property is "rented" on purpose: it must NOT appear in Explore.
const String _olayaImg = 'assets/images/property_olaya.jpg';
const String _malqaImg = 'assets/images/property_malqa.jpg';
const String _hittinImg = 'assets/images/property_hittin.jpg';

const List<Property> sampleProperties = [
  Property(
    propertyId: '10482',
    ownerId: 'owner_1',
    title: 'محل تجاري بالدور الأرضي، العليا',
    district: 'العليا',
    city: 'الرياض',
    propertyType: PropertyType.shop,
    areaSqm: 85,
    rentPrice: 78000,
    status: PropertyStatus.available,
    latitude: 24.6936,
    longitude: 46.6853,
    imageUrls: [_olayaImg],
    description:
        'محل بواجهة زجاجية كبيرة ومدخل مباشر من الشارع الرئيسي، معروض من المالك مباشرة.',
    hasParking: true,
  ),
  Property(
    propertyId: '10517',
    ownerId: 'owner_2',
    title: 'محل زاوية، الملقا',
    district: 'الملقا',
    city: 'الرياض',
    propertyType: PropertyType.shop,
    areaSqm: 70,
    rentPrice: 72000,
    status: PropertyStatus.available,
    latitude: 24.8070,
    longitude: 46.6100,
    imageUrls: [_malqaImg],
    description: 'محل على زاوية بواجهتين، قريب من مجمع مكاتب.',
    hasParking: false,
  ),
  Property(
    propertyId: '10533',
    ownerId: 'owner_1',
    title: 'وحدة على الشارع، حطين',
    district: 'حطين',
    city: 'الرياض',
    propertyType: PropertyType.shop,
    areaSqm: 60,
    rentPrice: 65000,
    status: PropertyStatus.available,
    latitude: 24.7650,
    longitude: 46.6050,
    imageUrls: [_hittinImg],
    description: 'وحدة تجارية على شارع رئيسي ضمن مجمع تجاري.',
    hasParking: true,
  ),
  Property(
    propertyId: '10561',
    ownerId: 'owner_3',
    title: 'مكتب إداري، الياسمين',
    district: 'الياسمين',
    city: 'الرياض',
    propertyType: PropertyType.office,
    areaSqm: 110,
    rentPrice: 90000,
    status: PropertyStatus.available,
    latitude: 24.8250,
    longitude: 46.6400,
    imageUrls: [_olayaImg],
    description: 'مكتب في الدور الأول مع غرفة اجتماعات.',
    hasParking: true,
  ),
  Property(
    propertyId: '10578',
    ownerId: 'owner_3',
    title: 'كشك تجاري، النرجس',
    district: 'النرجس',
    city: 'الرياض',
    propertyType: PropertyType.kiosk,
    areaSqm: 15,
    rentPrice: 30000,
    status: PropertyStatus.available,
    latitude: 24.8550,
    longitude: 46.6700,
    imageUrls: [_hittinImg],
    // description and hasParking left empty on purpose,
    // to test how pages handle missing optional data.
  ),
  Property(
    propertyId: '10590',
    ownerId: 'owner_2',
    title: 'محل مؤجر، قرطبة',
    district: 'قرطبة',
    city: 'الرياض',
    propertyType: PropertyType.shop,
    areaSqm: 90,
    rentPrice: 80000,
    status: PropertyStatus.rented, // must be hidden from Explore
    latitude: 24.8110,
    longitude: 46.7300,
    imageUrls: [_malqaImg],
  ),
];
