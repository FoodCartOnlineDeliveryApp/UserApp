import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mealup/screen_animation_utils/transitions.dart';
import 'package:mealup/screens/about_app_screen.dart';
import 'package:mealup/screens/about_company_screen.dart';
import 'package:mealup/screens/auth/change_password_user.dart';
import 'package:mealup/screens/faqs_screen.dart';
import 'package:mealup/screens/feedback_and_support_screen.dart';
import 'package:mealup/screens/languages_screen.dart';
import 'package:mealup/screens/privacy_policy_screen.dart';
import 'package:mealup/screens/terms_of_use_screen.dart';
import 'package:mealup/utils/SharedPreferenceUtil.dart';
import 'package:mealup/utils/app_toolbar.dart';
import 'package:mealup/utils/constants.dart';
import 'package:mealup/utils/localization/language/languages.dart';
import 'edit_personal_information.dart';
import 'manage_your_location.dart';

class SettingScreen extends StatefulWidget {
  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {

  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: Scaffold(
        appBar: ApplicationToolbar(
          appbarTitle: Languages.of(context)!.screenSetting,
        ),
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                  constraints:
                      BoxConstraints(minHeight: viewportConstraints.maxHeight),
                  child: Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                      image: AssetImage('images/ic_background_image.png'),
                      fit: BoxFit.cover,
                    )),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        SettingMenuWidget(
                            onClick: () {
                              Navigator.of(context).push(Transitions(
                                  transitionType: TransitionType.fade,
                                  curve: Curves.bounceInOut,
                                  reverseCurve: Curves.fastLinearToSlowEaseIn,
                                  widget: EditProfileInformation()));
                            },
                            strMenuName:
                                Languages.of(context)!.labelEditPersonalInfo),
                        SettingMenuWidget(
                            onClick: () {
                              Navigator.of(context).push(Transitions(
                                  transitionType: TransitionType.fade,
                                  curve: Curves.bounceInOut,
                                  reverseCurve: Curves.fastLinearToSlowEaseIn,
                                  widget: ManageYourLocation()));
                            },
                            strMenuName:
                                Languages.of(context)!.labelManageYourLocation),
                        SettingMenuWidget(
                            onClick: () {
                              Navigator.of(context).push(Transitions(
                                  transitionType: TransitionType.fade,
                                  curve: Curves.bounceInOut,
                                  reverseCurve: Curves.fastLinearToSlowEaseIn,
                                  widget: ChangePasswordUser()));
                            },
                            strMenuName:
                                Languages.of(context)!.labelChangePassword),
                        SettingMenuWidget(
                            onClick: () {
                              Navigator.of(context).push(Transitions(
                                  transitionType: TransitionType.fade,
                                  curve: Curves.bounceInOut,
                                  reverseCurve: Curves.fastLinearToSlowEaseIn,
                                  widget: LanguagesScreen()));
                            },
                            strMenuName: Languages.of(context)!.labelLanguage),
                        SettingMenuWidget(
                            onClick: () {
                              Navigator.of(context).push(Transitions(
                                  transitionType: TransitionType.fade,
                                  curve: Curves.bounceInOut,
                                  reverseCurve: Curves.fastLinearToSlowEaseIn,
                                  widget: AboutApp()));
                            },
                            strMenuName: Languages.of(context)!.labelAboutApp),
                        SettingMenuWidget(
                            onClick: () {
                              Navigator.of(context).push(Transitions(
                                  transitionType: TransitionType.fade,
                                  curve: Curves.bounceInOut,
                                  reverseCurve: Curves.fastLinearToSlowEaseIn,
                                  widget: AboutCompanyScreen()));
                            },
                            strMenuName:
                                Languages.of(context)!.labelAboutCompany),
                        SettingMenuWidget(
                            onClick: () {
                              Navigator.of(context).push(Transitions(
                                  transitionType: TransitionType.fade,
                                  curve: Curves.bounceInOut,
                                  reverseCurve: Curves.fastLinearToSlowEaseIn,
                                  widget: PrivacyPolicyScreen()));
                            },
                            strMenuName:
                                Languages.of(context)!.labelPrivacyPolicy),
                        SettingMenuWidget(
                            onClick: () {
                              Navigator.of(context).push(Transitions(
                                  transitionType: TransitionType.fade,
                                  curve: Curves.bounceInOut,
                                  reverseCurve: Curves.fastLinearToSlowEaseIn,
                                  widget: TermsOfUseScreen()));
                            },
                            strMenuName: Languages.of(context)!.labelTermOfUse),
                        SettingMenuWidget(
                            onClick: () {
                              Navigator.of(context).push(Transitions(
                                  transitionType: TransitionType.fade,
                                  curve: Curves.bounceInOut,
                                  reverseCurve: Curves.fastLinearToSlowEaseIn,
                                  widget: FeedbackAndSupportScreen()));
                            },
                            strMenuName:
                                Languages.of(context)!.labelFeedbacknSup),
                        SettingMenuWidget(
                            onClick: () {
                              Navigator.of(context).push(Transitions(
                                  transitionType: TransitionType.fade,
                                  curve: Curves.bounceInOut,
                                  reverseCurve: Curves.fastLinearToSlowEaseIn,
                                  widget: FAQsScreen()));
                            },
                            strMenuName:
                            Languages.of(context)!.labelFAQs),
                        Padding(
                          padding: const EdgeInsets.only(top: 30, bottom: 50),
                          child: Text(
                            Languages.of(context)!.labelMealupAppVersion +
                                SharedPreferenceUtil.getString(Constants.appSettingAndroidCustomerVersion),
                            style: TextStyle(
                                color: Constants.colorGray,
                                fontSize: ScreenUtil().setSp(12),
                                fontFamily: Constants.appFont),
                            textAlign: TextAlign.center,
                          ),
                        )
                      ],
                    ),
                  )),
            );
          },
        ),
      ),
    );
  }

}

// ignore: must_be_immutable
class SettingMenuWidget extends StatelessWidget {
  Function onClick;
  String? strImagePath, strMenuName;

  SettingMenuWidget({required this.onClick, required this.strMenuName});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onClick as void Function()?,
      child: Container(
        height: 60,
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                margin: EdgeInsets.only(top: 10),
                child: Text(
                  strMenuName!,
                  style:
                      TextStyle(fontSize: 16, fontFamily: Constants.appFont),
                ),
              ),
              Container(
                alignment: Alignment.center,
                child: Divider(
                  thickness: 1,
                  color: Color(0xffcccccc),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
