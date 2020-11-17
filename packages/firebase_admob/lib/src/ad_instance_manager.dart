// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

// ignore_for_file: deprecated_member_use_from_same_package

import 'dart:async';

import 'package:firebase_admob/src/mobile_ads.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:quiver/collection.dart';

import 'firebase_admob.dart';

/// Loads and disposes [BannerAds] and [InterstitialAds].
AdInstanceManager instanceManager = AdInstanceManager(
  'plugins.flutter.io/firebase_admob',
);

/// Maintains access to loaded [Ad] instances.
class AdInstanceManager {
  AdInstanceManager(String channelName)
      : assert(channelName != null),
        channel = MethodChannel(
          channelName,
          StandardMethodCodec(AdMessageCodec()),
        ) {
    channel.setMethodCallHandler((MethodCall call) async {
      assert(call.method == 'onAdEvent');

      final int adId = call.arguments['adId'];
      final String eventName = call.arguments['eventName'];

      final Ad ad = adFor(adId);
      if (ad != null) {
        _onAdEvent(ad, eventName, call.arguments);
      } else {
        debugPrint('$Ad with id `$adId` is not available for $eventName.');
      }
    });
  }

  int _nextAdId = 0;
  final BiMap<int, Ad> _loadedAds = BiMap<int, Ad>();
  final Set<Ad> _onAdLoadedAds = <Ad>{};

  bool onAdLoadedCalled(Ad ad) => _onAdLoadedAds.contains(ad);

  /// Invokes load and dispose calls.
  final MethodChannel channel;

  void _onAdEvent(Ad ad, String eventName, Map<dynamic, dynamic> arguments) {
    assert(ad != null);
    switch (eventName) {
      case 'onAdLoaded':
        _onAdLoadedAds.add(ad);
        ad.listener?.onAdLoaded(ad);
        break;
      case 'onAdFailedToLoad':
        ad.listener?.onAdFailedToLoad(ad, arguments['loadAdError']);
        break;
      case 'onNativeAdClicked':
        ad.listener?.onNativeAdClicked(ad);
        break;
      case 'onNativeAdImpression':
        ad.listener?.onNativeAdImpression(ad);
        break;
      case 'onAdOpened':
        ad.listener?.onAdOpened(ad);
        break;
      case 'onApplicationExit':
        ad.listener?.onApplicationExit(ad);
        break;
      case 'onAdClosed':
        ad.listener?.onAdClosed(ad);
        break;
      case 'onAppEvent':
        ad.listener?.onAppEvent(ad, arguments['name'], arguments['data']);
        break;
      case 'onRewardedAdUserEarnedReward':
        assert(arguments['rewardItem'] != null);
        ad.listener?.onRewardedAdUserEarnedReward(ad, arguments['rewardItem']);
        break;
      default:
        debugPrint('invalid ad event name: $eventName');
    }
  }

  /// Returns null if an invalid [adId] was passed in.
  Ad adFor(int adId) => _loadedAds[adId];

  /// Returns null if an invalid [Ad] was passed in.
  int adIdFor(Ad ad) => _loadedAds.inverse[ad];

  /// Starts loading the ad if not previously loaded.
  ///
  /// Loading also terminates if ad is already in the process of loading.
  Future<void> loadBannerAd(BannerAd ad) {
    if (adIdFor(ad) != null) {
      return null;
    }

    final int adId = _nextAdId++;
    _loadedAds[adId] = ad;
    final Ad bannerAd = adFor(adId);
    return channel.invokeMethod<void>(
      'loadBannerAd',
      <dynamic, dynamic>{
        'adId': adId,
        'adUnitId': bannerAd.adUnitId,
        'request': ad.request,
        'size': ad.size,
      },
    );
  }

  Future<void> loadInterstitialAd(InterstitialAd ad) {
    if (adIdFor(ad) != null) {
      return null;
    }

    final int adId = _nextAdId++;
    _loadedAds[adId] = ad;
    final InterstitialAd interstitialAd = adFor(adId);
    return channel.invokeMethod<void>(
      'loadInterstitialAd',
      <dynamic, dynamic>{
        'adId': adId,
        'adUnitId': interstitialAd.adUnitId,
        'request': interstitialAd.request,
      },
    );
  }

  /// Starts loading the ad if not previously loaded.
  ///
  /// Loading also terminates if ad is already in the process of loading.
  Future<void> loadNativeAd(NativeAd ad) {
    if (adIdFor(ad) != null) {
      return null;
    }

    final int adId = _nextAdId++;
    _loadedAds[adId] = ad;
    final Ad nativeAd = adFor(adId);
    return channel.invokeMethod<void>(
      'loadNativeAd',
      <dynamic, dynamic>{
        'adId': adId,
        'adUnitId': nativeAd.adUnitId,
        'request': ad.request,
        'publisherRequest': ad.publisherRequest,
        'factoryId': ad.factoryId,
        'customOptions': ad.customOptions,
      },
    );
  }

  /// Starts loading the ad if not previously loaded.
  ///
  /// Loading also terminates if ad is already in the process of loading.
  Future<void> loadRewardedAd(RewardedAd ad) {
    if (adIdFor(ad) != null) {
      return null;
    }

    final int adId = _nextAdId++;
    _loadedAds[adId] = ad;
    final RewardedAd rewardedAd = adFor(adId);
    return channel.invokeMethod<void>(
      'loadRewardedAd',
      <dynamic, dynamic>{
        'adId': adId,
        'adUnitId': rewardedAd.adUnitId,
        'request': rewardedAd.request,
      },
    );
  }

  /// Starts loading the ad if not previously loaded.
  ///
  /// Loading also terminates if ad is already in the process of loading.
  Future<void> loadPublisherBannerAd(PublisherBannerAd ad) {
    if (adIdFor(ad) != null) {
      return null;
    }

    final int adId = _nextAdId++;
    _loadedAds[adId] = ad;
    return channel.invokeMethod<void>(
      'loadPublisherBannerAd',
      <dynamic, dynamic>{
        'adId': adId,
        'sizes': ad.sizes,
        'adUnitId': ad.adUnitId,
        'request': ad.request,
      },
    );
  }

  /// Loads an ad if not currently loading or loaded.
  ///
  /// Loading also terminates if ad is already in the process of loading.
  Future<void> loadPublisherInterstitialAd(PublisherInterstitialAd ad) {
    if (adIdFor(ad) != null) {
      return null;
    }

    final int adId = _nextAdId++;
    _loadedAds[adId] = ad;
    return channel.invokeMethod<void>(
      'loadPublisherInterstitialAd',
      <dynamic, dynamic>{
        'adId': adId,
        'adUnitId': ad.adUnitId,
        'request': ad.request,
      },
    );
  }

  /// Free the plugin resources associated with this ad.
  ///
  /// Disposing a banner ad that's been shown removes it from the screen.
  /// Interstitial ads can't be programmatically removed from view.
  Future<void> disposeAd(Ad ad) {
    _onAdLoadedAds.remove(ad);

    final int adId = adIdFor(ad);
    final Ad disposedAd = _loadedAds.remove(adId);
    if (disposedAd == null) {
      return null;
    }
    return channel.invokeMethod<void>(
      'disposeAd',
      <dynamic, dynamic>{
        'adId': adId,
      },
    );
  }

  /// Display an [AdWithoutView] that is overlaid on top of the application.
  Future<void> showAdWithoutView(AdWithoutView ad) {
    assert(
      adIdFor(ad) != null,
      '$Ad has not been loaded or has already been disposed.',
    );

    return channel.invokeMethod<void>(
      'showAdWithoutView',
      <dynamic, dynamic>{
        'adId': adIdFor(ad),
      },
    );
  }
}

class AdMessageCodec extends StandardMessageCodec {
  const AdMessageCodec();

  // The type values below must be consistent for each platform.
  static const int _valueAdSize = 128;
  static const int _valueAdRequest = 129;
  static const int _valueDateTime = 130;
  static const int _valueMobileAdGender = 131;
  static const int _valueRewardItem = 132;
  static const int _valueLoadAdError = 133;
  static const int _valuePublisherAdRequest = 134;
  static const int _valueInitializationState = 135;
  static const int _valueAdapterStatus = 136;
  static const int _valueInitializationStatus = 137;

  @override
  void writeValue(WriteBuffer buffer, dynamic value) {
    if (value is AdSize) {
      buffer.putUint8(_valueAdSize);
      writeValue(buffer, value.width);
      writeValue(buffer, value.height);
    } else if (value is AdRequest) {
      buffer.putUint8(_valueAdRequest);
      writeValue(buffer, value.keywords);
      writeValue(buffer, value.contentUrl);
      writeValue(buffer, value.birthday);
      writeValue(buffer, value.gender);
      writeValue(buffer, value.designedForFamilies);
      writeValue(buffer, value.childDirected);
      writeValue(buffer, value.testDevices);
      writeValue(buffer, value.nonPersonalizedAds);
    } else if (value is DateTime) {
      buffer.putUint8(_valueDateTime);
      writeValue(buffer, value.millisecondsSinceEpoch);
    } else if (value is MobileAdGender) {
      buffer.putUint8(_valueMobileAdGender);
      writeValue(buffer, value.index);
    } else if (value is RewardItem) {
      buffer.putUint8(_valueRewardItem);
      writeValue(buffer, value.amount);
      writeValue(buffer, value.type);
    } else if (value is LoadAdError) {
      buffer.putUint8(_valueLoadAdError);
      writeValue(buffer, value.code);
      writeValue(buffer, value.domain);
      writeValue(buffer, value.message);
    } else if (value is PublisherAdRequest) {
      buffer.putUint8(_valuePublisherAdRequest);
      writeValue(buffer, value.keywords);
      writeValue(buffer, value.contentUrl);
      writeValue(buffer, value.customTargeting);
      writeValue(buffer, value.customTargetingLists);
    } else if (value is AdapterInitializationState) {
      buffer.putUint8(_valueInitializationState);
      writeValue(buffer, describeEnum(value));
    } else if (value is AdapterStatus) {
      buffer.putUint8(_valueAdapterStatus);
      writeValue(buffer, value.state);
      writeValue(buffer, value.description);
      writeValue(buffer, value.latency);
    } else if (value is InitializationStatus) {
      buffer.putUint8(_valueInitializationStatus);
      writeValue(buffer, value.adapterStatuses);
    } else {
      super.writeValue(buffer, value);
    }
  }

  @override
  dynamic readValueOfType(dynamic type, ReadBuffer buffer) {
    switch (type) {
      case _valueAdSize:
        return AdSize(
          width: readValueOfType(buffer.getUint8(), buffer),
          height: readValueOfType(buffer.getUint8(), buffer),
        );
      case _valueAdRequest:
        return AdRequest(
          keywords: readValueOfType(buffer.getUint8(), buffer)?.cast<String>(),
          contentUrl: readValueOfType(buffer.getUint8(), buffer),
          birthday: readValueOfType(buffer.getUint8(), buffer),
          gender: readValueOfType(buffer.getUint8(), buffer),
          designedForFamilies: readValueOfType(buffer.getUint8(), buffer),
          childDirected: readValueOfType(buffer.getUint8(), buffer),
          testDevices:
              readValueOfType(buffer.getUint8(), buffer)?.cast<String>(),
          nonPersonalizedAds: readValueOfType(buffer.getUint8(), buffer),
        );
      case _valueDateTime:
        return DateTime.fromMillisecondsSinceEpoch(
            readValueOfType(buffer.getUint8(), buffer));
      case _valueMobileAdGender:
        int gender = readValueOfType(buffer.getUint8(), buffer);
        switch (gender) {
          case 1:
            return MobileAdGender.male;
          case 2:
            return MobileAdGender.female;
        }
        return MobileAdGender.unknown;
      case _valueRewardItem:
        return RewardItem(
          readValueOfType(buffer.getUint8(), buffer),
          readValueOfType(buffer.getUint8(), buffer),
        );
      case _valueLoadAdError:
        return LoadAdError(
          readValueOfType(buffer.getUint8(), buffer),
          readValueOfType(buffer.getUint8(), buffer),
          readValueOfType(buffer.getUint8(), buffer),
        );
      case _valuePublisherAdRequest:
        return PublisherAdRequest(
          keywords: readValueOfType(buffer.getUint8(), buffer)?.cast<String>(),
          contentUrl: readValueOfType(buffer.getUint8(), buffer),
          customTargeting: readValueOfType(buffer.getUint8(), buffer)
              ?.cast<String, String>(),
          customTargetingLists: _deepMapCast<String>(
            readValueOfType(buffer.getUint8(), buffer),
          ),
        );
      case _valueInitializationState:
        switch (readValueOfType(buffer.getUint8(), buffer)) {
          case 'notReady':
            return AdapterInitializationState.notReady;
          case 'ready':
            return AdapterInitializationState.ready;
        }
        throw ArgumentError();
      case _valueAdapterStatus:
        final AdapterInitializationState state =
            readValueOfType(buffer.getUint8(), buffer);
        final String description = readValueOfType(buffer.getUint8(), buffer);

        double latency = readValueOfType(buffer.getUint8(), buffer)?.toDouble();
        // Android provides this value as an int in milliseconds while iOS
        // provides this value as a double in seconds.
        if (latency != null &&
            defaultTargetPlatform == TargetPlatform.android) {
          latency /= 1000;
        }

        return AdapterStatus(state, description, latency);
      case _valueInitializationStatus:
        return InitializationStatus(
          readValueOfType(buffer.getUint8(), buffer)
              .cast<String, AdapterStatus>(),
        );
      default:
        return super.readValueOfType(type, buffer);
    }
  }

  Map<String, List<T>> _deepMapCast<T>(Map<dynamic, dynamic> map) {
    if (map == null) return null;
    return map.map<String, List<T>>(
      (dynamic key, dynamic value) => MapEntry<String, List<T>>(
        key,
        value?.cast<T>(),
      ),
    );
  }
}