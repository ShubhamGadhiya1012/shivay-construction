import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';

class LocationHelper {
  Future<Position?> getCurrentLocation(BuildContext context) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // ignore: use_build_context_synchronously
      bool? userResponse = await _showLocationServicesDialog(context);
      if (userResponse == true) {
        await Geolocator.openLocationSettings();
      }
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return Future.error('Location services are disabled.');
      }
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );

    return await Geolocator.getCurrentPosition(
      locationSettings: locationSettings,
    );
  }

  Future<bool?> _showLocationServicesDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Location Services Disabled',
            style: TextStyles.kSemiBoldOutfit(
              color: kColorPrimary,
              fontSize: FontSizes.k24FontSize,
            ),
          ),
          content: Text(
            'Location services are disabled. Please enable them to continue.',
            style: TextStyles.kRegularOutfit(
              color: kColorSecondary,
              fontSize: FontSizes.k18FontSize,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Open Settings',
                style: TextStyles.kRegularOutfit(
                  color: kColorPrimary,
                  fontSize: FontSizes.k20FontSize,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }
}
