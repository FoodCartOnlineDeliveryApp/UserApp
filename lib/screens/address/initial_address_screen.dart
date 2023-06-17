import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mealup/model/UserAddressListModel.dart';
import 'package:mealup/retrofit/api_header.dart';
import 'package:mealup/retrofit/api_client.dart';
import 'package:mealup/retrofit/base_model.dart';
import 'package:mealup/retrofit/server_error.dart';
import 'package:mealup/screen_animation_utils/transitions.dart';
import 'package:mealup/screens/bottom_navigation/dashboard_screen.dart';
import 'package:mealup/utils/SharedPreferenceUtil.dart';
import 'package:mealup/utils/app_toolbar.dart';
import 'package:mealup/utils/constants.dart';
import 'package:mealup/utils/localization/language/languages.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import '../../utils/rounded_corner_app_button.dart';
import 'add_address_screen.dart';

class InitialAddressScreen extends StatefulWidget {
  const InitialAddressScreen({super.key});

  @override
  State<InitialAddressScreen> createState() => _InitialAddressScreenState();
}

class _InitialAddressScreenState extends State<InitialAddressScreen> {
  List<UserAddressListData> _userAddressList = [];
  late Position currentLocation;
  double _currentLatitude = 0.0;

  double _currentLongitude = 0.0;
  BitmapDescriptor? _markerIcon;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _createMarkerImageFromAsset(context);
    Constants.checkNetwork().whenComplete(() => callGetUserAddresses());
  }

  Future<void> _createMarkerImageFromAsset(BuildContext context) async {
    setState(() {
      isLoading = true;
    });
    if (_markerIcon == null) {
      BitmapDescriptor bitmapDescriptor =
          await _bitmapDescriptorFromSvgAsset(context, 'images/ic_marker.svg');
      setState(() {
        _markerIcon = bitmapDescriptor;
      });
    }
  }

  Future<BitmapDescriptor> _bitmapDescriptorFromSvgAsset(
      BuildContext context, String assetName) async {
    String svgString =
        await DefaultAssetBundle.of(context).loadString(assetName);
    DrawableRoot svgDrawableRoot = await svg.fromSvgString(svgString, '');

    MediaQueryData queryData = MediaQuery.of(context);
    double devicePixelRatio = queryData.devicePixelRatio;
    double width = 32 * devicePixelRatio;
    double height = 32 * devicePixelRatio;

    ui.Picture picture = svgDrawableRoot.toPicture(size: Size(width, height));

    ui.Image image = await picture.toImage(width.toInt(), height.toInt());
    ByteData? bytes = await (image.toByteData(format: ui.ImageByteFormat.png));
    return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
  }

  getUserLocation() async {
    currentLocation = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    _currentLatitude = currentLocation.latitude;
    _currentLongitude = currentLocation.longitude;
  }

  Future<BaseModel<UserAddressListModel>> callGetUserAddresses() async {
    UserAddressListModel response;
    try {
      Constants.onLoading(context);
      _userAddressList.clear();
      response = await RestClient(RetroApi().dioData()).userAddress();
      print(response.success);
      Constants.hideDialog(context);
      if (response.success!) {
        await getUserLocation();
        setState(() {
          _userAddressList.addAll(response.data!);
          isLoading = false;
        });
        if (_userAddressList.length == 0) {
          Navigator.of(context).pushReplacement(
            Transitions(
              transitionType: TransitionType.slideUp,
              curve: Curves.bounceInOut,
              reverseCurve: Curves.fastLinearToSlowEaseIn,
              widget: AddAddressScreen(
                isFromAddAddress: true,
                fromInitialAddress: true,
                currentLat: _currentLatitude,
                currentLong: _currentLongitude,
                marker: _markerIcon,
              ),
            ),
          );
        }
      } else {
        Constants.toastMessage(Languages.of(context)!.labelNoData);
      }
    } catch (error, stacktrace) {
      Constants.hideDialog(context);
      print("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(360, 690));
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        appBar: ApplicationToolbar(
          appbarTitle: Languages.of(context)!.labelSetLocation,
        ),
        body: Container(
          margin: EdgeInsets.only(left: 20, right: 20),
          decoration: BoxDecoration(
              image: DecorationImage(
            image: AssetImage('images/ic_background_image.png'),
            fit: BoxFit.cover,
          )),
          child: LayoutBuilder(
            builder:
                (BuildContext context, BoxConstraints viewportConstraints) {
              return ConstrainedBox(
                constraints:
                    BoxConstraints(minHeight: viewportConstraints.maxHeight),
                child: isLoading
                    ? SizedBox()
                    :
                    // _userAddressList.length == 0
                    //     ? AddAddressScreen(
                    //         isFromAddAddress: false,
                    //         fromInitialAddress: true,
                    //         currentLat: _currentLatitude,
                    //         currentLong: _currentLongitude,
                    //         marker: _markerIcon,
                    //       )
                    //     :
                    SingleChildScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(
                                  left: ScreenUtil().setWidth(30),
                                  top: ScreenUtil().setHeight(5),
                                  bottom: ScreenUtil().setHeight(5)),
                              child: Text(
                                Languages.of(context)!.labelSavedAddress,
                                style: TextStyle(
                                    fontSize: ScreenUtil().setSp(14),
                                    fontFamily: Constants.appFontBold),
                              ),
                            ),
                            Column(
                              children: [
                                ListView.builder(
                                  physics: ClampingScrollPhysics(),
                                  shrinkWrap: true,
                                  scrollDirection: Axis.vertical,
                                  itemCount: _userAddressList.length,
                                  itemBuilder:
                                      (BuildContext context, int index) =>
                                          InkWell(
                                    onTap: () {
                                      Navigator.pop(context);
                                      SharedPreferenceUtil.putString(
                                          'selectedLat',
                                          _userAddressList[index].lat!);
                                      SharedPreferenceUtil.putString(
                                          'selectedLng',
                                          _userAddressList[index].lang!);
                                      SharedPreferenceUtil.putString(
                                          Constants.selectedAddress,
                                          _userAddressList[index].address!);
                                      SharedPreferenceUtil.putInt(
                                          Constants.selectedAddressId,
                                          _userAddressList[index].id);
                                      Navigator.of(context).push(Transitions(
                                          transitionType:
                                              TransitionType.slideUp,
                                          curve: Curves.bounceInOut,
                                          reverseCurve:
                                              Curves.fastLinearToSlowEaseIn,
                                          widget: DashboardScreen(0)));
                                    },
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 10, left: 30, bottom: 8),
                                          child: Text(
                                            _userAddressList[index].type != null
                                                ? _userAddressList[index].type!
                                                : '',
                                            style: TextStyle(
                                                fontFamily:
                                                    Constants.appFontBold,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            SvgPicture.asset(
                                              'images/ic_map.svg',
                                              width: 18,
                                              height: 18,
                                              color: Constants.colorTheme,
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 12, top: 2),
                                                child: Text(
                                                  _userAddressList[index]
                                                      .address!,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      fontFamily:
                                                          Constants.appFont,
                                                      color:
                                                          Constants.colorBlack),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Divider(
                                          thickness: 1,
                                          color: Color(0xffcccccc),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 20),
                                  child: Text(
                                    "OR",
                                    style: TextStyle(
                                        fontSize: ScreenUtil().setSp(14),
                                        fontFamily: Constants.appFontBold),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 50),
                              child: Center(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(vertical: 15),
                                    primary: Constants.colorTheme,
                                    onPrimary: Constants.colorWhite,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.pin_drop_outlined,
                                        color: Colors.white,
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        "Pick from map",
                                        style: TextStyle(
                                            fontFamily: Constants.appFont,
                                            fontWeight: FontWeight.w900,
                                            color: Constants.colorWhite,
                                            fontSize: 16.0),
                                      ),
                                    ],
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).push(Transitions(
                                        transitionType: TransitionType.fade,
                                        curve: Curves.bounceInOut,
                                        reverseCurve:
                                            Curves.fastLinearToSlowEaseIn,
                                        widget: AddAddressScreen(
                                          isFromAddAddress: true,
                                          fromInitialAddress: true,
                                          currentLat: _currentLatitude,
                                          currentLong: _currentLongitude,
                                          marker: _markerIcon,
                                        )));
                                  },
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            )
                          ],
                        ),
                      ),
              );
            },
          ),
        ),
      ),
    );
  }
}
