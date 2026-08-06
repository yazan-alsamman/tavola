class AppDimensions {
  static const double tinySpacing = 4.0;
  static const double compactSpacing = 6.0;
  static const double pagePadding = 16.0;
  static const double sectionSpacing = 16.0;
  static const double smallSpacing = 8.0;
  static const double regularSpacing = 12.0;

  static const double cardRadius = 20.0;
  static const double searchBarRadius = 30.0;
  static const double pillRadius = 999.0;
  static const double cardBorderWidth = 1.0;
  static const double checkboxBorderWidth = 1.5;

  /// Branded confirm dialog (cancel / reschedule / logout).
  static const double confirmDialogMaxWidth = 360.0;
  static const double confirmDialogHorizontalInset = 28.0;
  static const double confirmDialogPadding = 28.0;
  static const double confirmDialogRadius = 28.0;
  static const double confirmDialogIconContainerSize = 64.0;
  static const double confirmDialogIconSize = 30.0;
  static const double confirmDialogIconFillAlpha = 0.18;
  static const double confirmDialogBarrierAlpha = 0.45;
  static const double confirmDialogElevationBlur = 28.0;
  static const double confirmDialogElevationY = 14.0;
  static const double confirmDialogElevationOpacity = 0.18;
  static const double confirmDialogTitleFontSize = 24.0;
  static const double confirmDialogMessageFontSize = 15.0;
  static const double confirmDialogMessageLineHeight = 1.45;
  static const double confirmDialogButtonMinHeight = 52.0;
  static const double confirmDialogButtonFontSize = 16.0;
  static const double confirmDialogButtonGap = 12.0;

  static const double imageHeight = 140.0;
  static const double compactRestaurantImageHeight = 104.0;
  static const double compactRestaurantContentPadding = 12.0;
  static const double compactBadgePaddingHorizontal = 8.0;
  static const double compactBadgePaddingVertical = 4.0;
  static const double compactFavoriteButtonSize = 34.0;
  static const double compactFavoriteIconSize = 18.0;
  static const double bookingRestaurantCardSpacing = 12.0;
  static const double promoHeight = 190.0;
  static const double homeOccasionScrollTopInset = 6.0;
  static const double homeOccasionScrollMinDelta = 8.0;
  static const Duration homeOccasionScrollDuration = Duration(
    milliseconds: 900,
  );
  static const double reservationCardHeight = 136.0;
  static const double reservationImageWidth = 130.0;
  /// Single-line slots so Date / Time / Guests values stay on one baseline.
  static const double reservationDetailLabelLineHeight = 16.0;
  static const double reservationDetailValueLineHeight = 20.0;
  static const double reservationDetailCompactValueFontSize = 12.0;
  static const double onboardingReservationCardHeight = 124.0;
  static const double onboardingReservationImageWidth = 96.0;
  static const double contentPadding = 16.0;
  static const double compactHorizontalPadding = 14.0;
  static const double compactVerticalPadding = 8.0;
  static const double buttonHorizontalPadding = 20.0;
  static const double buttonVerticalPadding = 14.0;
  static const double tabHorizontalPadding = 2.0;
  static const double tabVerticalPadding = 14.0;
  static const double profileSectionTabMinHeight = 52.0;
  static const double profileSectionTabHorizontalPadding = 6.0;
  static const double profileSectionTabVerticalPadding = 10.0;
  static const double profileSectionTabGap = 6.0;
  static const double profileSectionTabFontSize = 11.0;
  static const double profileSectionTabLineHeight = 1.2;
  static const double badgePaddingHorizontal = 10.0;
  static const double badgePaddingVertical = 6.0;
  static const double notificationBadgeMinSize = 16.0;
  static const double notificationBadgePaddingHorizontal = 4.0;
  static const double notificationBadgeFontSize = 9.0;
  static const double notificationUnreadDotSize = 8.0;

  static const double iconButtonSize = 40.0;
  static const double circleBackButtonSize = 44.0;
  static const double circleBackButtonElevation = 3.0;
  static const double circleBackIconSize = 22.0;
  static const double circleBackIconOffset = 2.0;
  static const double guestLoginButtonHorizontalPadding = 10.0;
  static const double guestLoginButtonVerticalPadding = 6.0;
  static const double guestLoginButtonFontSize = 11.0;
  static const double authFieldRadius = 20.0;
  static const double authFieldVerticalPadding = 18.0;
  static const double authFieldMinHeight = 56.0;
  static const double authPhonePrefixWidth = 136.0;
  static const double authPhoneDividerHeight = 28.0;
  static const double authPhoneFlagWidth = 22.0;

  /// ITU NSN bounds used only when country mobile metadata is unavailable.
  static const int authPhoneFallbackMinNsnLength = 3;
  static const int authPhoneFallbackMaxNsnLength = 17;
  static const int authMinPasswordLength = 12;
  static const int otpCodeLength = 6;
  static const int otpResendDelaySeconds = 60;
  static const Duration otpResendTickInterval = Duration(seconds: 1);
  static const int profileFeaturedRestaurantCount = 3;
  static const double compactRestaurantBodyFontSize = 13.0;
  static const double authPasswordIconSize = 22.0;
  static const double otpFieldSize = 48.0;
  static const double otpFieldMinSize = 36.0;
  static const double otpFieldRadius = 16.0;
  static const double otpFieldFocusedBorderWidth = 1.5;
  static const double otpIconContainerSize = 64.0;
  static const double otpIconSize = 28.0;
  static const double smallIconSize = 16.0;
  static const double mediumIconSize = 20.0;
  static const double imageFallbackIconSize = 36.0;
  static const double settingsIconSize = 22.0;
  static const double avatarSize = 48.0;
  static const double avatarRadius = 25.0;
  static const double avatarIconSize = 26.0;
  static const double avatarPickerMaxWidth = 1024.0;
  static const double avatarPickerMaxHeight = 1024.0;
  static const int avatarPickerImageQuality = 85;
  static const double exploreBannerIconContainerSize = 44.0;
  static const double exploreBannerIconRadius = 14.0;
  static const double exploreBannerIconSize = 22.0;
  static const double exploreBannerBodyLineHeight = 1.45;
  static const double reservationHistoryCardBlurSigma = 32.0;
  static const double reservationHistoryOrbSize = 128.0;
  static const double reservationHistoryAccentOrbAlpha = 0.58;
  static const double reservationHistoryPrimaryOrbAlpha = 0.16;
  static const double reservationHistorySoftOrbAlpha = 0.4;
  static const double reservationHistoryGlassSurfaceAlpha = 0.72;
  static const double reservationHistoryGlassAccentAlpha = 0.28;
  static const double reservationHistoryGlassPrimaryAlpha = 0.1;
  static const double reservationHistoryBorderAlpha = 0.14;
  static const double reservationHistoryStatusFillAlpha = 0.92;
  static const double reservationHistoryImageSize = 72.0;
  static const double reservationHistoryImageRadius = 16.0;
  static const double reservationHistoryMetaIconSize = 14.0;
  static const double reservationHistoryCardElevationBlur = 20.0;
  static const double reservationHistoryCardElevationOpacity = 0.1;
  static const double reservationHistoryCardElevationY = 8.0;
  static const double reservationHistoryTitleLetterSpacing = 0.2;
  static const double reservationHistoryStatusLetterSpacing = 0.6;
  static const double reservationHistoryHeaderIconFillAlpha = 0.45;
  static const double reservationReviewStarSize = 22.0;
  static const double reservationReviewSheetStarSize = 36.0;
  static const double reservationReviewSheetMaxHeightFactor = 0.88;
  static const double reservationReviewPhotoThumbSize = 64.0;
  static const int reviewMinRating = 1;
  static const int reviewMaxRating = 5;
  static const int reviewCommentMaxLength = 500;
  static const int reviewsMaxSyncPages = 10;
  static const double profileReservationsEmptyIconContainer = 64.0;
  static const double profileReservationsEmptyIconSize = 30.0;

  static const double headerHeight = 72.0;
  static const double notificationsHeaderHeight = 112.0;
  static const double notificationsHeaderHeightWithAction = 156.0;
  static const double notificationsTitleFontSize = 24.0;
  static const double notificationsTitleLetterSpacing = 2.0;
  static const double headerLogoIconSize = 27.0;
  static const double headerNotificationIconSize = 24.0;
  static const double headerProfileSize = 38.0;

  /// Person glyph inside the header avatar circle (filled brand chip).
  static const double headerProfileIconSize = 24.0;
  static const double headerProfileBorderWidth = 1.0;

  static const double conciergeContentMaxWidth = 720.0;
  static const double conciergeStatusDotSize = 9.0;
  static const double conciergeMessageWidthFactor = 0.82;
  static const double conciergeComposerRadius = 26.0;
  static const double conciergeSendButtonSize = 44.0;
  static const double conciergeSendIconSize = 20.0;
  static const double conciergeBubbleRadius = 18.0;
  static const double conciergeBubbleTailRadius = 4.0;
  static const double conciergeHeaderAvatarSize = 40.0;
  static const double mapInitialZoom = 14.2;
  static const double mapInitialLatitude = 51.5124;
  static const double mapInitialLongitude = -0.1472;

  /// User location (geolocator) configuration.
  static const Duration locationRequestTimeout = Duration(seconds: 15);
  static const Duration locationServiceCheckTimeout = Duration(seconds: 8);

  /// Meters — `0` means every movement update is eligible.
  static const int locationDistanceFilterMeters = 0;
  static const double locationStatusIconSize = 22.0;
  static const double locationStatusMinHeight = 48.0;
  static const double mapSecondRestaurantLatitude = 51.5097;
  static const double mapSecondRestaurantLongitude = -0.1418;

  /// Offset applied per pin when branch coordinates are missing.
  static const double mapPinLatitudeStep = 0.004;
  static const double mapPinLongitudeStep = 0.004;
  static const double mapMarkerSize = 64.0;
  static const double mapMarkerCoreSize = 42.0;
  static const double mapMarkerIconSize = 21.0;
  static const double mapMarkerMinScale = 0.92;
  static const double mapMarkerMaxScale = 1.08;
  static const double mapMarkerMinGlow = 8.0;
  static const double mapMarkerMaxGlow = 24.0;
  static const double mapMarkerMinGlowOpacity = 0.22;
  static const double mapMarkerMaxGlowOpacity = 0.48;
  static const double mapCardMaxWidth = 560.0;
  static const double mapErrorCardElevation = 2.0;
  static const double mapCardImageHeight = 112.0;
  static const double mapCardSaveIconSize = 19.0;
  static const Duration mapMarkerShineDuration = Duration(milliseconds: 1400);

  /// Per-restaurant branch lookup budget so map pins never hang indefinitely.
  static const Duration mapBranchResolveTimeout = Duration(seconds: 8);

  static const double occasionGridSpacing = 12.0;
  static const double occasionCardRadius = 28.0;
  static const double occasionIconContainerSize = 54.0;
  static const double occasionIconSize = 27.0;
  static const double occasionGridAspectRatio = 1.0;
  static const double occasionSelectedBorderWidth = 2.0;
  static const int occasionGridColumnCount = 2;
  static const int occasionWideGridColumnCount = 4;
  static const double occasionWideBreakpoint = 700.0;

  static const double reservationCounterButtonSize = 48.0;
  static const double reservationCounterIconSize = 24.0;
  static const double reservationChoiceHeight = 48.0;
  static const double reservationChoiceWidth = 148.0;

  static const double floorPlanLegendDotSize = 12.0;
  static const double floorPlanTableSize = 54.0;
  static const double floorPlanLargeTableSize = 66.0;
  static const double floorPlanTableMinSizeFactor = 0.7;
  static const double floorPlanTableRadius = 16.0;
  static const double floorPlanMapWidth = 520.0;
  static const double floorPlanMapHeight = 420.0;

  // Onboarding / local Select Table preview layout (not API data).
  static const int previewTableSeatsW1 = 12;
  static const int previewTableSeatsR3 = 8;
  static const int previewTableSeatsC2 = 6;
  static const int previewTableSeatsA2 = 4;
  static const int previewTableSeatsV5 = 2;
  static const int previewTableSeatsB4 = 6;
  static const int previewTableSeatsP6 = 10;
  static const int previewTableSeatsM8 = 8;
  static const int previewTableSeatsT7 = 4;
  static const double previewTableMapXW1 = 228;
  static const double previewTableMapYW1 = 62;
  static const double previewTableMapXR3 = 234;
  static const double previewTableMapYR3 = 188;
  static const double previewTableMapXC2 = 234;
  static const double previewTableMapYC2 = 322;
  static const double previewTableMapXA2 = 158;
  static const double previewTableMapYA2 = 168;
  static const double previewTableMapXV5 = 158;
  static const double previewTableMapYV5 = 252;
  static const double previewTableMapXB4 = 348;
  static const double previewTableMapYB4 = 168;
  static const double previewTableMapXP6 = 348;
  static const double previewTableMapYP6 = 252;
  static const double previewTableMapXM8 = 448;
  static const double previewTableMapYM8 = 210;
  static const double previewTableMapXT7 = 448;
  static const double previewTableMapYT7 = 322;
  static const double floorPlanMapAspectRatio =
      floorPlanMapHeight / floorPlanMapWidth;
  static const double floorPlanContainerHeight = 460.0;
  static const double floorPlanMapMinScale = 1.0;
  static const double floorPlanMapMaxScale = 2.4;
  static const double floorPlanAvailablePulseMin = 1.0;
  static const double floorPlanAvailablePulseMax = 1.045;
  static const double floorPlanIdleShadowBlur = 10.0;
  static const double floorPlanLiveDotSize = 8.0;
  static const double floorPlanLiveDotGlowBlur = 6.0;
  static const double floorPlanLiveDotMinOpacity = 0.72;
  static const double floorPlanLiveDotMaxOpacity = 1.0;
  static const Duration floorPlanLiveTimeUpdateInterval = Duration(seconds: 30);
  static const Duration floorPlanLiveDotPulseDuration = Duration(
    milliseconds: 1600,
  );
  static const double floorPlanSelectedShadowBlur = 18.0;
  static const double floorPlanMapInset = 10.0;
  static const double floorPlanMapInnerPadding = 18.0;
  static const double floorPlanWindowHeightFactor = 0.18;
  static const double floorPlanDiningLineFactor = 0.34;
  static const double floorPlanServiceLineFactor = 0.66;
  static const double floorPlanServiceSplitFactor = 0.64;
  static const double floorPlanZoneLabelXFactor = 0.42;
  static const double floorPlanServiceLabelXFactor = 0.68;
  static const double floorPlanEntranceXFactor = 0.5;
  static const double floorPlanEntranceLabelXFactor = 0.445;
  static const double floorPlanEntranceWidthFactor = 0.18;
  static const double floorPlanEntranceHeight = 14.0;
  static const double floorPlanEntranceBottomOffset = 16.0;
  static const double floorPlanEntranceLabelBottomOffset = 28.0;
  static const double floorPlanZoneLabelTop = 26.0;
  static const double floorPlanZoneLabelOffsetY = 10.0;
  static const double floorPlanZoneLabelMaxWidthFactor = 0.28;
  static const double floorPlanHairlineStroke = 1.0;
  static const double tableDescriptionFieldMinHeight = 96.0;
  static const double dashedBorderStrokeWidth = 1.5;
  static const double dashedBorderDashLength = 4.0;
  static const double dashedBorderGapLength = 3.0;
  static const double dividerHeight = 1.0;

  static const double detailsHeroHeight = 380.0;
  static const double detailsHeroBlurSigma = 18.0;
  static const double detailsHeroOverlayHeight = 220.0;
  static const double detailsHeroFadeStart = 0.0;
  static const double detailsHeroFadeMid = 0.28;
  static const double detailsHeroFadeEnd = 0.62;
  static const double detailsAmenityMinHeight = 34.0;
  static const double detailsAmenityRadius = 12.0;
  static const double detailsMenuPriceMinWidth = 56.0;
  static const double detailsLocationIconSize = 28.0;
  static const double restaurantCardActionVerticalPadding = 12.0;
  static const double restaurantCardActionHorizontalPadding = 20.0;
  static const double restaurantCardActionRadius = 12.0;
  static const double restaurantCardActionBorderWidth = 1.5;
  static const double restaurantCardActionTopSpacing = 14.0;
  static const double restaurantCardActionGap = 10.0;
  static const double restaurantCardActionMinHeight = 42.0;
  static const int randomMenuItemCount = 12;

  static const Duration apiConnectTimeout = Duration(seconds: 20);

  /// Hard ceiling for any ApiClient call (covers iOS DNS hangs that ignore
  /// Dio connectTimeout on physical devices).
  static const Duration apiHardRequestTimeout = Duration(seconds: 25);

  /// Caps Keychain / Secure Storage waits so login/guest never hang forever.
  static const Duration secureStorageTimeout = Duration(seconds: 3);

  /// Hard ceiling for an auth submit (login / sign-up / forgot-password) UI wait.
  static const Duration authSubmitTimeout = Duration(seconds: 25);

  /// Ceiling for `POST /auth/refresh` only — shorter than [authSubmitTimeout]
  /// so a dead host cannot stall every authenticated API for a full login wait.
  static const Duration authRefreshTimeout = Duration(seconds: 8);

  /// Ceiling for `POST /auth/logout` / logout-all before local session clear.
  /// Must stay short so Profile Log out never feels frozen offline.
  static const Duration authLogoutTimeout = Duration(seconds: 8);

  /// After a transient refresh failure, skip proactive refresh this long so
  /// Home catalog calls are not serially blocked. Reactive 401 refresh still runs.
  static const Duration accessTokenRefreshFailureCooldown = Duration(
    seconds: 30,
  );

  static const int apiDefaultPage = 1;
  static const int apiDefaultLimit = 20;

  /// Default search radius for `GET /discovery/restaurants/nearby`.
  static const double nearbySearchRadiusKm = 50;

  /// Max nearby/catalog restaurants to probe for a published offer.
  static const int homeOfferCandidateProbeLimit = 8;

  /// Default `limit` for `GET /conversations` (cursor pagination).
  static const int conversationsPageSize = apiDefaultLimit;

  /// Max height factor for the start-conversation restaurant picker sheet.
  static const double conversationsPickerMaxHeightFactor = 0.7;

  /// Home cuisine / occasion / restaurants loads must not spin forever.
  /// Ceiling for Home taxonomy loads — matches [apiHardRequestTimeout] so the
  /// UI never waits longer than [ApiClient] will keep the Future alive.
  static const Duration homeCatalogLoadTimeout = apiHardRequestTimeout;

  /// Hour/minute (24h) for reservation time-slot indices (display labels are localized).
  static const List<int> reservationSlotHours = <int>[19, 20, 20, 21];
  static const List<int> reservationSlotMinutes = <int>[30, 0, 30, 15];

  /// Hours for experience-duration indices (display labels are localized).
  static const List<double> reservationDurationHours = <double>[1.5, 2.0, 2.5];

  static const int reservationDefaultDinerCount = 2;
  static const Duration apiReceiveTimeout = Duration(seconds: 20);
  static const Duration apiSendTimeout = Duration(seconds: 20);

  /// Refresh access token this long before JWT `exp`.
  static const Duration accessTokenRefreshSkew = Duration(minutes: 2);
  static const double progressIndicatorStrokeWidth = 2.0;
  static const double tinyIconSize = 12.0;

  static const double confirmationOverlayBlurSigma = 12.0;
  static const double onboardingConciergeGlassBlurSigma = 18.0;
  static const double onboardingConciergeGlowOrbSize = 112.0;
  static const double confirmationCardMaxWidth = 380.0;
  static const double confirmationHeaderHeight = 196.0;
  static const double confirmationIconContainerSize = 56.0;
  static const double confirmationIconSize = 30.0;
  static const double confirmationTornToothHeight = 14.0;
  static const int confirmationTornToothCount = 18;
  static const double confirmationBottomPadding = 28.0;
  static const int confirmationLabelFlex = 2;
  static const int confirmationValueFlex = 3;

  static const double bottomNavShadowBlur = 10.0;
  static const double bottomNavShadowOffsetY = -2.0;
  static const double selectedNavFontSize = 12.0;
  static const double unselectedNavFontSize = 11.0;
  static const double selectedNavIconSize = 26.0;
  static const double unselectedNavIconSize = 22.0;

  /// Material Symbols fill for the selected (pressed) bottom-tab icon.
  static const double selectedNavIconFill = 1.0;
  static const double unselectedNavIconFill = 0.0;

  static const double hoverElevation = 8.0;
  static const double hoverScale = 1.025;
  static const double cardPressedScale = 1.035;
  static const double cardHoverSlideY = -0.006;
  static const double buttonHoverScale = 1.04;
  static const double buttonPressedScale = 0.98;
  static const double buttonHoverSlideY = -0.025;
  static const double shadowBlur = 16.0;
  static const double shadowOffsetY = 4.0;
  static const double shadowOpacity = 0.16;

  static const double splashInitialScale = 1.0;
  static const double splashInitialOpacity = 1.0;
  static const double splashShineStart = -1.6;
  static const double splashShineEnd = 1.6;
  static const double splashGradientCenterY = -0.15;
  static const double splashGradientRadius = 1.15;
  static const double splashShineWidth = 0.4;
  static const List<double> splashShineStops = [
    0.0,
    0.32,
    0.43,
    0.5,
    0.57,
    0.68,
    1.0,
  ];

  /// Welcome -> Login / Guest bridge (Splash-matched brand hold).
  static const double welcomeTransitionBrandFontSize = 42.0;
  static const double welcomeTransitionBrandLetterSpacing = 6.0;
  static const double welcomeTransitionMarkMaxWidthFactor = 0.78;
  static const double welcomeTransitionIndicatorSize = 22.0;
  static const double welcomeTransitionLavenderWidth = 56.0;
  static const double welcomeTransitionLavenderHeight = 68.0;
  static const double welcomeTransitionInitialOpacity = 0.0;
  static const double welcomeTransitionInitialScale = 0.96;
  static const Duration welcomeTransitionEnterDuration = Duration(
    milliseconds: 320,
  );
  static const Duration welcomeTransitionFadeDuration = Duration(
    milliseconds: 480,
  );

  /// Minimum time the branded bridge stays visible so prep never races past
  /// the first paint (Login prep is often synchronous and was invisible).
  static const Duration welcomeTransitionMinDisplayDuration = Duration(
    milliseconds: 900,
  );

  /// Settings logout branded bridge hold before Welcome.
  static const Duration logoutTransitionDisplayDuration = Duration(seconds: 2);

  static const Duration hoverDuration = Duration(milliseconds: 220);
  static const Duration floorPlanPulseDuration = Duration(milliseconds: 1800);
  static const Duration splashIntroDuration = Duration(milliseconds: 1400);
  static const Duration splashShineDuration = Duration(milliseconds: 2200);
  static const Duration splashShineDelay = Duration(milliseconds: 650);
  static const Duration splashBrandDrawDuration = Duration(milliseconds: 4000);
  static const Duration splashBrandDrawDelay = Duration(milliseconds: 350);

  /// Visible Splash hold. Must cover brand draw + [splashDestinationPrepLead]
  /// so the next route can finish warming before navigation.
  static const Duration splashDisplayDuration = Duration(milliseconds: 8000);

  /// Start warming the post-Splash route this long before leaving Splash.
  static const Duration splashDestinationPrepLead = Duration(seconds: 2);

  /// Ceiling for destination warm-up (local DI / asset decode). Network catalog
  /// loads are fire-and-forget from Splash so this must stay short.
  static const Duration splashDestinationPrepTimeout = Duration(seconds: 3);

  /// Max extra wait at navigation time after [splashReadyDuration]. If prep is
  /// still running, leave Splash anyway — never freeze on Home HTTP.
  static const Duration splashNavigationPrepGrace = Duration(milliseconds: 500);

  /// Wall-clock wait before leaving Splash — at least brand draw end plus the
  /// destination prep lead so Home controllers are never created mid-draw and
  /// the next page can reach a warm first frame before the transition.
  static Duration get splashReadyDuration {
    final Duration brandDrawEnd =
        splashBrandDrawDelay + splashBrandDrawDuration;
    final Duration minimumWithPrep = brandDrawEnd + splashDestinationPrepLead;
    if (splashDisplayDuration >= minimumWithPrep) {
      return splashDisplayDuration;
    }
    return minimumWithPrep;
  }

  /// Max wait while warming the splash lavender into the image cache in `main`.
  static const Duration splashAssetPrecacheTimeout = Duration(
    milliseconds: 800,
  );

  /// Idle Home promo decode during Welcome/Login — never blocks navigation.
  static const Duration homeAssetPrecacheTimeout = Duration(milliseconds: 1200);

  /// Fraction into a letter where the T-bar triggers that glyph's reveal.
  static const double splashLetterRevealAtFactor = 0.02;

  /// Reveal span as a fraction of letter width (longer = slower, smoother).
  static const double splashLetterRevealSpanFactor = 0.78;
  static const double splashLetterRise = 12.0;
  static const double splashLetterSlide = 6.0;
  static const double splashLetterStartScale = 0.88;

  /// Draw-progress ranges for each T-stroke segment (shared by paint + reveal).
  static const double splashStrokeStemStart = 0.0;
  static const double splashStrokeStemEnd = 0.22;
  static const double splashStrokeBarBeforeStart = 0.18;
  static const double splashStrokeBarBeforeEnd = 0.42;
  static const double splashStrokeBarAfterStart = 0.48;
  static const double splashStrokeBarAfterEnd = 0.78;
  static const double splashStrokeTipStart = 0.72;
  static const double splashStrokeTipEnd = 1.0;

  /// Share of bar-after segment spent moving horizontally before the L drop.
  static const double splashStrokeBarAfterHorizPortion = 0.55;
  static const double splashBarStartInsetFactor = 0.45;
  static const double splashBarEndOnLFactor = 0.35;
  static const double splashTipStartOnLFactor = 0.55;
  static const double splashLDropBottomFactor = 0.9;
  static const double splashTStemBottomFactor = 0.92;
  static const double splashBrandFontSize = 96.0;
  static const double splashBrandLetterSpacing = 2.0;
  static const double splashBrandStrokeWidth = 5.5;
  static const double splashBrandTipStrokeWidth = 4.4;
  static const double splashBrandSerifDepth = 9.0;
  static const double splashBrandMaxWidthFactor = 0.9;
  static const double splashLavenderWidth = 88.0;
  static const double splashLavenderHeight = 104.0;
  static const double splashLavenderTiltDegrees = -28.0;

  /// How far the sprig base sits into the T-bar cut (downward).
  static const double splashLavenderBarOverlap = 8.0;

  /// Where the cut/stem sits across the first 'a' (0=left edge, 1=right).
  static const double splashLavenderOnAFactor = 0.64;

  /// Fine horizontal tweak in logical px after [splashLavenderOnAFactor].
  static const double splashLavenderHorizontalNudge = 0.0;
  static const double splashLavenderBarGapHalf = 12.0;

  /// Alignment.x of the stem tip in r11 (tip is ~5% from the left edge).
  static const double splashLavenderPivotX = -0.90;
  static const double splashLavenderStartScale = 0.78;
  static const double splashLavenderEndScale = 1.0;
  static const double splashLavenderSidePadFactor = 0.4;

  /// Longer window so the sprig eases in slowly with the T cut.
  static const double splashLavenderRevealSpread = 0.58;

  /// Draw progress when the T stroke reaches the cut (end of bar-before-gap).
  static const double splashLavenderRevealAt = 0.34;

  /// How far above the seat the sprig starts before settling down.
  static const double splashLavenderDropDistance = 72.0;

  /// Extra upright tilt at entrance (degrees); settles to [splashLavenderTiltDegrees].
  static const double splashLavenderEntranceTiltExtra = 14.0;
  static const double splashTStemWidthFactor = 0.55;
  static const double splashBarHeightFactor = 0.12;
  static const double splashLWidthFactor = 0.42;
  static const double splashTipLengthFactor = 0.92;
  static const Duration settingsLanguageToggleAnimDuration = Duration(
    milliseconds: 200,
  );
  static const Duration languageSwitchDisplayDuration = Duration(seconds: 3);
  static const Duration languageSwitchIntroDuration = Duration(
    milliseconds: 450,
  );
  static const Duration languageSwitchCoverDelay = Duration(milliseconds: 80);
  static const Duration languageSwitchApplyDelay = Duration(milliseconds: 500);
  static const double languageSwitchInitialScale = 0.92;
  static const double languageSwitchIconContainerSize = 72.0;
  static const double languageSwitchIconSize = 32.0;
  static const double languageSwitchProgressSize = 28.0;
  static const double languageSwitchProgressStroke = 2.5;

  static const int onboardingPageCount = 5;
  static const Duration onboardingWelcomePulseDuration = Duration(
    milliseconds: 2800,
  );
  static const Duration onboardingWelcomeShimmerDuration = Duration(
    milliseconds: 3200,
  );
  static const double onboardingWelcomeRingSizeFactor = 0.72;
  static const double onboardingWelcomeLineWidthFactor = 0.42;
  static const double onboardingWelcomeLineHeight = 2.0;
  static const double onboardingWelcomeOrbAccentAlpha = 0.45;
  static const double onboardingWelcomeOrbSecondaryAlpha = 0.18;
  static const double onboardingWelcomeRingBorderAlpha = 0.35;
  static const double onboardingGlassAccentOrbAlpha = 0.34;
  static const double onboardingGlassSecondaryOrbAlpha = 0.28;
  static const double onboardingGlassPanelFillAlpha = 0.72;
  static const double onboardingGlassPanelBorderAlpha = 0.28;
  static const double onboardingGlassDividerAlpha = 0.16;
  static const double onboardingGlassLightFillAlpha = 0.92;
  static const double onboardingGlassLightBorderAlpha = 0.24;
  static const double onboardingGlassTileFillAlpha = 0.12;
  static const double onboardingGlassTileBorderAlpha = 0.18;
  static const double onboardingPreviewChipFillAlpha = 0.14;
  static const double onboardingPreviewBorderAlpha = 0.2;
  static const double onboardingPreviewSoftBorderAlpha = 0.16;
  static const double onboardingPreviewMutedFillAlpha = 0.1;
  static const double onboardingPreviewFillAlpha = 0.16;
  static const double onboardingPreviewDisabledFillAlpha = 0.08;
  static const double onboardingConciergeBubbleFillAlpha = 0.92;
  static const double onboardingConciergeGlowAlpha = 0.35;
  static const double onboardingDotSize = 8.0;
  static const double onboardingDotActiveWidth = 22.0;
  static const double onboardingDotSpacing = 6.0;
  static const double onboardingSectionRadius = 16.0;
  static const double onboardingSectionMaxWidth = 340.0;
  static const double onboardingSectionPadding = 12.0;
  static const double onboardingPartyChipSize = 30.0;
  static const double onboardingPartyChipRadius = 8.0;
  static const double onboardingTablePreviewHeight = 58.0;
  static const double onboardingTablePreviewRadius = 12.0;
  static const double onboardingFloorPlanPreviewHeight = 148.0;
  static const double onboardingCompactCounterHeight = 28.0;
  static const double onboardingQrCodeSize = 76.0;
  static const double onboardingDateChipRadius = 12.0;
  static const double onboardingInviteButtonRadius = 12.0;
  static const double onboardingInviteIconSize = 18.0;
  static const double onboardingSectionIconSize = 18.0;
  static const double onboardingInviteButtonVerticalPadding = 10.0;
  static const double onboardingWelcomeOrbSize = 180.0;
  static const double onboardingWelcomeTitleSize = 42.0;
  static const double onboardingWelcomeBrandSize = 56.0;
  static const double onboardingWelcomeLetterSpacing = 6.0;
  static const Duration onboardingWelcomeDuration = Duration(
    milliseconds: 1600,
  );
  static const Duration onboardingPageEntranceDuration = Duration(
    milliseconds: 1050,
  );
  static const double onboardingDinematePageTopOffset = 24.0;
  static const Duration onboardingDotAnimDuration = Duration(milliseconds: 280);
  static const double onboardingPageFadeFactor = 0.5;
  static const double onboardingPageScaleFactor = 0.08;
  static const double onboardingPageSlideY = 28.0;
  static const double onboardingPageSlideX = 18.0;
  static const double onboardingMiniCardHeight = 64.0;
  static const double onboardingMiniCardImageWidth = 72.0;
  static const double onboardingConfirmedBannerRadius = 14.0;
  static const double onboardingInfoCardRadius = 14.0;
  static const double onboardingCodeFieldRadius = 10.0;
  static const double onboardingActionTileRadius = 12.0;
  static const double onboardingConfirmedIconSize = 20.0;
  static const double onboardingActionIconSize = 18.0;
  static const double onboardingCopyIconSize = 18.0;
  static const double onboardingContentMaxWidth = 340.0;
  static const double onboardingActionTilePaddingVertical = 10.0;
  static const double onboardingRewardsCardRadius = 18.0;
  static const double onboardingRewardsProgressHeight = 6.0;
  static const double onboardingRewardsProgressValue = 0.24;
  static const double onboardingRewardsMedalSize = 36.0;
  static const double onboardingRewardsChipRadius = 8.0;
  static const double onboardingRewardsBadgeSize = 18.0;
  static const double onboardingRewardsOfferRadius = 12.0;
  static const double favoriteCuisinesIconCircleSize = 72.0;
  static const double favoriteCuisinesIconSize = 34.0;
  static const double favoriteCuisinesChipSpacing = 10.0;
  static const double favoriteCuisinesChipHorizontalPadding = 16.0;
  static const double favoriteCuisinesChipVerticalPadding = 10.0;
  static const double favoriteCuisinesMaxWidth = 420.0;

  static const double welcomeTitleAlignX = 0.0;

  /// Places TAVOLA just under the baked-in T on [AppImages.welcomeHero].
  static const double welcomeTitleAlignY = -0.28;
  static const double welcomeTitleMaxWidthFactor = 0.56;
  static const double welcomeTitleOffsetY = 0.0;
  static const double welcomeTitleFontSize = 48.0;
  static const double welcomeTitleLetterSpacing = 6.5;
  static const double welcomeBottomGradientHeight = 320.0;
  static const double welcomeBottomGradientStart = 0.0;
  static const double welcomeBottomGradientMid = 0.55;
  static const double welcomeShineBandExtent = 0.85;
  static const Duration welcomeShineDuration = Duration(milliseconds: 5200);
  static const List<double> welcomeShineStops = [
    0.0,
    0.34,
    0.44,
    0.5,
    0.56,
    0.66,
    1.0,
  ];
}
