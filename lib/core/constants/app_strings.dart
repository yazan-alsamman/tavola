import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppStrings {

  static const String appName = 'TAVOLA';
  static const String appTitle = appName;
  static const String splashTitle = appName;
  /// Splash wordmark matching the branded Tavola lockup.
  static const String splashBrandMark = 'Tavola';
  static String get signIn => 'SIGN IN'.tr;
  static String get loginSignUp => 'LOGIN / SIGN UP'.tr;
  static String get login => 'LOGIN'.tr;
  static String get signUp => 'SIGN UP'.tr;
  static String get continueAsGuest => 'CONTINUE AS GUEST'.tr;

  static String get onboardingWelcomeTo => 'WELCOME TO'.tr;
  static const String onboardingWelcomeBrand = appName;
  static String get onboardingSwipeHint => 'SWIPE TO EXPLORE'.tr;
  static String get onboardingGetStarted => 'GET STARTED'.tr;
  static String get onboardingSelectTable => 'Select your table'.tr;
  static String get onboardingSelectTableHint => 'Preview the floor plan and pick your favorite seat.'.tr;
  static String get onboardingPreferredTime => 'Preferred time'.tr;
  static String get onboardingInviteFriends => 'Invite friends'.tr;
  static String get onboardingInviteFriendsHint => 'Make it a group experience! (Optional)'.tr;
  static String get onboardingInviteFriendsAction => 'Invite friends'.tr;
  static String get onboardingBookHeadline => 'BOOK IN A FEW TAPS'.tr;
  static String get onboardingBookHint => 'Live availability, instant booking, and smart reminders.'.tr;
  static String get onboardingConfirmHeadline => 'STAY IN CONTROL'.tr;
  static String get onboardingConfirmHint => 'Manage details, share your code, and reach your host in one place.'.tr;
  static String get onboardingRewardsHeadline => 'DINE AND EARN'.tr;
  static String get onboardingRewardsHint => 'Earn points with every reservation and unlock refined dining privileges.'.tr;
  static String get onboardingDinemateHeadline => 'Not finding a place to eat? Ask Tavola AI'.tr;
  static String get onboardingDinemateHint => 'Tavola AI guides you to the perfect table for any occasion.'.tr;
  static const String onboardingDinemateTitle = 'Tavola AI';
  static String get onboardingDinemateStatus => 'Always ready'.tr;
  static String get onboardingDinemateComposerHint =>
      'Ask Tavola AI for a recommendation...'.tr;
  static String get onboardingDinemateUserMessage => 'Find me an intimate table for two tonight.'.tr;
  static String get onboardingDinemateAiMessage => 'Olive & Oak has a quiet window table at 8:30 PM — soft lighting and garden views.'.tr;
  static String get onboardingLoyaltyRewards => 'TAVOLA REWARDS'.tr;
  static String get onboardingLoyaltyTierBronze => 'Host Member'.tr;
  static String get onboardingLoyaltyPointsValue => '120 pts'.tr;
  static String get onboardingLoyaltyProgressTitle =>
      'NEXT: SILVER HOST'.tr;
  static String get onboardingLoyaltyPointsToSilver =>
      '380 points remaining'.tr;
  static String get onboardingLoyaltyTotalPointsValue => '120';
  static String get onboardingLoyaltyTotalPointsLabel => 'Points'.tr;
  static String get onboardingLoyaltyClaimedValue => '2';
  static String get onboardingLoyaltyClaimedLabel => 'Redeemed'.tr;
  static String get onboardingLoyaltyAvailableValue => '1';
  static String get onboardingLoyaltyAvailableLabel => 'Ready'.tr;
  static String get onboardingLoyaltyDiscounts => 'Exclusive Offers'.tr;
  static String get onboardingLoyaltyDiscountsCount => '2';
  static String get onboardingLoyaltyOfferOneTitle =>
      'Complimentary amuse-bouche'.tr;
  static String get onboardingLoyaltyOfferOnePoints => '180';
  static String get onboardingLoyaltyOfferOnePlace =>
      'Cedar Table · Mayfair'.tr;
  static String get onboardingLoyaltyOfferOneNeed =>
      'Need 60 more points'.tr;
  static String get onboardingLoyaltyOfferTwoTitle =>
      'Late seating priority'.tr;
  static String get onboardingLoyaltyOfferTwoPoints => '100';
  static String get onboardingLoyaltyOfferTwoPlace =>
      'Amber Terrace · Hillview'.tr;
  static String get onboardingLoyaltyOfferClaimedTag => 'Unlocked'.tr;
  static String get onboardingLoyaltyBenefitsTitle =>
      'Member Privileges'.tr;
  static String get onboardingLoyaltyBenefitOne =>
      'Early access to peak tables'.tr;
  static String get onboardingLoyaltyBenefitTwo =>
      'Birthday tasting gift'.tr;
  static String get onboardingConfirmedMessage => 'Your table is reserved at Otako Sushi. Share the code with your guests and arrive ready to unwind.'.tr;
  static String get onboardingBookingInformations =>
      'Reservation summary'.tr;
  static String get onboardingConfirmationCode =>
      'Confirmation Code'.tr;
  static String get onboardingQrCodeLabel => 'QR CODE'.tr;
  static String get onboardingContactRestaurant => 'Quick actions'.tr;
  static String get onboardingCall => 'Call'.tr;
  static String get onboardingChangeDate => 'Change date'.tr;
  static String get onboardingDirections => 'Directions'.tr;
  static String get onboardingCancel => 'Cancel'.tr;
  static String get onboardingPartyGuestsLabel => '2 Guests'.tr;
  static String get onboardingReservationDateLabel =>
      'Fri, 19 Aug'.tr;
  static String get onboardingBookingDateLabel =>
      'Fri, 19 Aug · 8:00 PM'.tr;
  static String get onboardingTableLabel =>
      'Table V5 · Window'.tr;
  static String get onboardingRestaurantCuisine =>
      'Japanese · Sushi'.tr;
  static String get onboardingTableSelectedBadge => 'SELECTED'.tr;
  static String get onboardingTableWindowSeat => 'Window seat'.tr;
  static String get onboardingToday => 'TODAY'.tr;
  static String get onboardingTomorrow => 'TOMORROW'.tr;
  static String get onboardingMonthAug => 'AUG'.tr;
  static String get onboardingDayOneWeekday => 'WED'.tr;
  static String get onboardingDayOneNumber => '17';
  static String get onboardingDayTwoWeekday => 'THU'.tr;
  static String get onboardingDayTwoNumber => '18';
  static String get onboardingDayThreeWeekday => 'FRI'.tr;
  static String get onboardingDayThreeNumber => '19';
  static String get onboardingDayFourWeekday => 'SAT'.tr;
  static String get onboardingDayFourNumber => '20';

  static const String onboardingCompletedKey = 'onboarding_completed';
  static const String favoriteCuisinesCompletedKey =
      'favorite_cuisines_completed';
  static const String localeLanguageCodeKey = 'locale_language_code';
  static const String favoriteCuisinesSelectedKey =
      'favorite_cuisines_selected';

  static String get favoriteCuisinesTitle => 'Favorite Cuisines'.tr;
  static String get favoriteCuisinesSubtitle => 'Select the cuisines you enjoy the most to get personalized recommendations.'.tr;
  static String get favoriteCuisinesSkip => 'Skip for Now'.tr;
  static String get favoriteCuisinesConfirm => 'Confirm'.tr;
  static String get cuisineAmerican => 'American'.tr;
  static String get cuisineCafe => 'Cafe'.tr;
  static String get cuisineChinese => 'Chinese'.tr;
  static String get cuisineFrench => 'French'.tr;
  static String get cuisineGreek => 'Greek'.tr;
  static String get cuisineLebanese => 'Lebanese'.tr;
  static String get cuisineMexican => 'Mexican'.tr;
  static String get cuisineSpanish => 'Spanish'.tr;
  static String get cuisineThai => 'Thai'.tr;
  static String get cuisineEmirati => 'Emirati'.tr;
  static String get loginInstruction =>
      'Login with your phone number and password'.tr;
  static String get signUpInstruction => 'Create your account with your details to start reserving tables.'.tr;
  static String get enterYourNumber => 'Enter your number'.tr;
  static String get searchCountry => 'Search country'.tr;

  static const String authDefaultCountryCode = 'AE';
  static const String authDefaultDialCode = '+971';
  static const List<String> authFavoriteDialCodes = [
    '+971',
    '+966',
    '+973',
    '+974',
    '+968',
  ];

  static String get enterYourPassword => 'Enter your password'.tr;
  static String get confirmYourPassword =>
      'Confirm your password'.tr;
  static String get passwordMismatch =>
      'Passwords do not match.'.tr;
  static String get authMinDigitsHint =>
      'Enter at least 8 digits.'.tr;
  static String get authPasswordHint => 'Use at least 8 characters with letters and numbers.'.tr;
  static String get authNameRequiredHint => 'Enter your name.'.tr;
  static String get enterYourName => 'Enter your name'.tr;
  static String get forgotPassword => 'Forgot password?'.tr;
  static String get checkYourWhatsapp =>
      'CHECK YOUR WHATSAPP'.tr;
  static String get otpInstruction =>
      'Enter the verification code we sent you.'.tr;
  static String get otpSentTo => 'We sent a code to'.tr;
  static String get resendIt => 'RESEND IT'.tr;
  static String get verifyOtp => 'VERIFY'.tr;
  static const String otpDefaultPhone = '+971 50 000 0000';
  static const String empty = '';
  static const String networkImagePrefix = 'http';

  static String get home => 'Home'.tr;
  static String get map => 'Map'.tr;
  static String get favorite => 'Favorite'.tr;
  static String get booking => 'Booking'.tr;
  static String get chat => 'Chat'.tr;
  static String get details => 'Details'.tr;
  static String get reservation => 'Reservation'.tr;
  static String get favorites => 'Favorites'.tr;
  static String get concierge => 'Concierge'.tr;
  static String get profile => 'Profile'.tr;
  static String get settings => 'Settings'.tr;
  static String get languageSettings => 'Language'.tr;
  static String get languageSettingsDescription =>
      'Switch the app between English and Arabic.'.tr;
  static String get languageEnglish => 'English'.tr;
  static String get languageArabic => 'Arabic'.tr;
  static String get languageSwitchingTitle => 'Changing language'.tr;
  static String get languageSwitchingSubtitle =>
      'Updating your dining experience'.tr;

  /// Resolves switch-overlay copy for [locale] without using the active GetX locale.
  static String languageSwitchingTitleFor(Locale locale) {
    return locale.languageCode == 'ar'
        ? 'جاري تغيير اللغة'
        : 'Changing language';
  }

  static String languageSwitchingSubtitleFor(Locale locale) {
    return locale.languageCode == 'ar'
        ? 'نحدّث تجربتك في التطبيق'
        : 'Updating your dining experience';
  }

  static String get reservations => 'Reservations'.tr;
  static String get payments => 'Payments'.tr;
  static String get activeDiningPlacements =>
      'Active dining placements'.tr;
  static String get partnerOwnerAccess =>
      'Partner&Owner access'.tr;
  static String get launchBoard => 'Launch Board'.tr;
  static String get searchHint => 'Search restaurants'.tr;
  static String get restaurantsNearYou =>
      'Restaurants near you'.tr;
  static String get cuisines => 'Cuisines'.tr;
  static String get occasions => 'Occasions'.tr;
  static String get viewAll => 'View all'.tr;

  static String get nearbyLocation => 'NEAR DUBAI, JBR'.tr;
  static String get allRestaurants => 'All Restaurants'.tr;
  static String get japanese => 'Japanese'.tr;
  static String get seafood => 'Seafood'.tr;
  static String get italian => 'Italian'.tr;
  static String get barbecue => 'BBQ'.tr;
  static String get specialOffer => 'Special Offer'.tr;
  static String get specialOfferDescription => 'Enjoy a premium dinner experience with chef-selected flavors and a warm atmosphere.'.tr;
  static String get bookNow => 'Book now'.tr;

  static String get profileUserName => 'Joan Pedro ';
  static String get partnerOwnerDescription => 'Unlock advanced restaurant management tools, exclusive analytics, and fast access to board controls with premium permissions.'.tr;
  static String get fineSystemConfigurations =>
      'Fine System Configurations'.tr;
  static String get reservationReminderNotifications =>
      'Reservation Reminder Notifications'.tr;
  static String get reservationReminderDescription => 'Receive 2-hour arrival warnings and hosts updates'.tr;
  static String get tablePreparedNotice =>
      'Table is Prepared Ready Notice'.tr;
  static String get tablePreparedDescription => 'Live alert when hostess prepares physical placement'.tr;
  static String get lateArrivalInform =>
      'Late Arrival Automatically Inform'.tr;
  static String get lateArrivalDescription => 'Let hosts know you are delayed via dynamic chat dispatches'.tr;
  static String get promotionsConciergeEvents =>
      'Promotions & Concierge Events'.tr;
  static String get promotionsConciergeDescription => 'Invitations for special Mayfair cellar wine pairings'.tr;
  static String get date => 'Date'.tr;
  static String get time => 'Time'.tr;
  static String get guests => 'Guests'.tr;
  static String get reservationDate => '12 Jul'.tr;
  static String get reservationTime => '08:30 PM'.tr;
  static String get reservationGuests => '4';

  static String get indian => 'Indian'.tr;
  static String get sushi => 'Sushi'.tr;
  static String get mediterranean => 'Mediterranean'.tr;
  static String get asian => 'Asian'.tr;
  static String get contemporary => 'Contemporary'.tr;
  static String get steakhouse => 'Steakhouse'.tr;
  static List<String> get favoriteCuisineOptions => [
        cuisineAmerican,
        cuisineCafe,
        cuisineChinese,
        cuisineFrench,
        cuisineGreek,
        indian,
        asian,
        italian,
        japanese,
        cuisineLebanese,
        mediterranean,
        barbecue,
        cuisineMexican,
        seafood,
        cuisineSpanish,
        cuisineThai,
        cuisineEmirati,
        sushi,
      ];
  static String get lunch => 'Lunch'.tr;
  static String get dinner => 'Dinner'.tr;
  static String get brunch => 'Brunch'.tr;
  static String get openNow => 'Open now'.tr;
  static String get booked => 'Booked'.tr;
  static String get limited => 'Limited'.tr;
  static String get saffronHouse => 'Saffron House';
  static String get otakoSushi => 'Otako Sushi';
  static String get oliveAndOak => 'Olive & Oak';
  static String get goldenLantern => 'Golden Lantern';
  static String get cedarTable => 'Cedar Table';
  static String get amberTerrace => 'Amber Terrace';
  static String get saffronDescription => 'Elegant dining experience with refined spice blends.'.tr;
  static String get otakoDescription =>
      'Sushi by a special chief.'.tr;
  static String get oliveDescription => 'Seasonal plates with warm, rustic charm.'.tr;
  static String get goldenDescription => 'Modern tasting menu with signature pours.'.tr;
  static String get cedarDescription => 'Comfort-forward plates and perfect steak .'.tr;
  static String get amberDescription =>
      'Premium cuts and candlelit evenings.'.tr;
  static String get oldTown => 'Old Town'.tr;
  static String get marinaBay => 'Marina Bay'.tr;
  static String get gardenStreet => 'Garden Street'.tr;
  static String get northDistrict => 'North District'.tr;
  static String get elmAvenue => 'Elm Avenue'.tr;
  static String get hillview => 'Hillview'.tr;

  static String get settingsScreen => 'Settings Screen'.tr;
  static String get detailsScreen => 'Details Screen'.tr;
  static String get favoritesScreen => 'Favorites Screen'.tr;
  static String get conciergeScreen => 'Concierge Screen'.tr;
  static String get reservationScreen => 'Reservation Screen'.tr;
  static String get reservationPreferences =>
      'Reservation Preferences'.tr;
  static String get selectYourRestaurant =>
      'Select your restaurant'.tr;
  static String get selectYourRestaurantSubtitle => 'Choose your dining destination to begin crafting a refined reservation experience.'.tr;
  static String get selectRestaurantUnavailable => 'This restaurant is not accepting new reservations right now.'.tr;
  static String get reservationPreferencesSubtitle => 'Choose your table and preferred seating to craft a refined dining experience.'.tr;
  static String get numberOfDiners => 'NUMBER OF DINERS'.tr;
  static String get availableTimeSlots =>
      'AVAILABLE TIME SLOTS'.tr;
  static String get experienceDuration =>
      'EXPERIENCE DURATION'.tr;
  static String get selectDate => 'SELECT DATE'.tr;
  static String get nextSelectTable => 'NEXT : SELECT TABLE'.tr;
  static String get reservationStepConfirmed => 'Your preferences have been saved. Table selection is next.'.tr;
  static String get timeSlotOne => '07:30 PM'.tr;
  static String get timeSlotTwo => '08:00 PM'.tr;
  static String get timeSlotThree => '08:30 PM'.tr;
  static String get timeSlotFour => '09:15 PM'.tr;
  static String get durationOnePointFive => '1.5 H'.tr;
  static String get durationTwo => '2 H'.tr;
  static String get durationTwoPointFive => '2.5 H'.tr;
  static List<String> get onboardingTimeSlots => [
        timeSlotOne,
        timeSlotTwo,
        timeSlotThree,
        timeSlotFour,
      ];

  static String get selectYourTable => 'Select your table'.tr;
  static String get selectTableSubtitle => 'Explore the dining room, choose an available table, and confirm your placement.'.tr;
  static String get tableAvailable => 'AVAILABLE'.tr;
  static String get tableReserved => 'RESERVED'.tr;
  static String get tableCleaning => 'CLEANING'.tr;
  static String get confirmReservation => 'CONFIRM RESERVATION'.tr;
  static String get floorPlan => 'FLOOR PLAN'.tr;
  static String get tableStatus => 'STATUS'.tr;
  static String get floorPlanNowTime => 'NOWTIME'.tr;
  static String get timePeriodAm => 'AM'.tr;
  static String get timePeriodPm => 'PM'.tr;
  static String get restaurantMapHint => 'Drag and pinch to explore the dining room'.tr;
  static String get windowSeating => 'WINDOW'.tr;
  static String get mainDining => 'DINING'.tr;
  static String get serviceArea => 'SERVICE'.tr;
  static String get entrance => 'ENTRANCE'.tr;
  static String get selectedTableLabel => 'SELECTED TABLE'.tr;
  static String get windowSeatBadge => 'WINDOW'.tr;
  static String get tableDescriptionA2 => 'Cozy corner table with soft ambient lighting — ideal for relaxed conversations.'.tr;
  static String get tableDescriptionV5 => 'Intimate two-seat table near the host stand, perfect for a quiet dinner.'.tr;
  static String get tableDescriptionP6 => 'Spacious booth with lounge seating and generous space for larger gatherings.'.tr;
  static String get tableDescriptionB4 => 'Corner booth reserved for a birthday celebration — unavailable for new bookings.'.tr;
  static String get tableDescriptionM8 => 'Large party table reserved for a corporate dinner event this evening.'.tr;
  static String get tableDescriptionT7 => 'Compact table being reset after lunch service — available again shortly.'.tr;
  static String get categoryExample => 'EXAMPLE'.tr;
  static const String textEllipsis = '…';
  static String get seatsSuffix => ' SEATS'.tr;
  static String get availableTableDescription => 'Premium window seating with panoramic city views, natural daylight, and a quiet atmosphere — ideal for intimate dining and special occasions.'.tr;
  static String get reservedTableNote => 'Currently held for an arriving party. Please choose another available table.'.tr;
  static String get cleaningTableNote => 'Being refreshed for the next service. This table will be ready shortly.'.tr;
  static String get reservationConfirmed =>
      'Your table has been reserved successfully.'.tr;
  static String get confirmed => 'Confirmed'.tr;
  static String get referencePrefix => 'REFERENCE : '.tr;
  static const String confirmationReferenceCode = 'TAV-8492';
  static String get dismiss => 'DISMISS'.tr;
  static String get confirmationRestaurant => 'RESTAURANT'.tr;
  static String get confirmationGuests => 'GUESTS'.tr;
  static String get confirmationDate => 'DATE'.tr;
  static String get confirmationTable => 'TABLE'.tr;
  static String get guestSingular => 'Guest'.tr;
  static String get guestPlural => 'guest_plural'.tr;
  static String get tablePrefix => 'Table'.tr;
  static const String dateTimeSeparator = ' · ';
  static List<String> get monthNames => [
        'January'.tr,
        'February'.tr,
        'March'.tr,
        'April'.tr,
        'May'.tr,
        'June'.tr,
        'July'.tr,
        'August'.tr,
        'September'.tr,
        'October'.tr,
        'November'.tr,
        'December'.tr,
      ];
  static List<String> get weekdayNames => [
        'Monday'.tr,
        'Tuesday'.tr,
        'Wednesday'.tr,
        'Thursday'.tr,
        'Friday'.tr,
        'Saturday'.tr,
        'Sunday'.tr,
      ];
  static String get selectTablePrompt =>
      'Please select an available table to continue.'.tr;
  static const String tableIdW1 = 'w1';
  static const String tableIdR3 = 'r3';
  static const String tableIdC2 = 'c2';
  static const String tableIdA2 = 'a2';
  static const String tableIdB4 = 'b4';
  static const String tableIdV5 = 'v5';
  static const String tableIdP6 = 'p6';
  static const String tableIdT7 = 't7';
  static const String tableIdM8 = 'm8';
  static const String tableLabelW1 = 'W1';
  static const String tableLabelR3 = 'R3';
  static const String tableLabelC2 = 'C2';
  static const String tableLabelA2 = 'A2';
  static const String tableLabelB4 = 'B4';
  static const String tableLabelV5 = 'V5';
  static const String tableLabelP6 = 'P6';
  static const String tableLabelT7 = 'T7';
  static const String tableLabelM8 = 'M8';

  static const String conciergeTitle = 'TAVOLA Concierge';
  static String get conciergeStatus => 'Active always'.tr;
  static String get conciergeGreeting => 'Good afternoon. I am your TAVOLA Concierge. I can guide you through premium seating, suggest perfect wine pairings, or coordinate an exquisite table reservation at any of our Mayfair partners.'.tr;
  static String get conciergeRecommendation => 'Would you like to review availability for "The Gilded Olive" tonight, or shall I recommend some curated Japanese plates at "Oma Sushi"?'.tr;
  static String get exploreGildedOlive =>
      'EXPLORE THE GILDED OLIVE'.tr;
  static String get conciergeMessageHint =>
      'Message your dining host...'.tr;
  static String get favoriteDiningSelections =>
      'Favorite dining selections'.tr;

  static String get mapSearchHint => 'Search Resturant'.tr;
  static String get reserveTable => 'Reserve Table'.tr;
  static String get viewDetails => 'View Details'.tr;
  static String get save => 'Save'.tr;
  static String get saved => 'Saved'.tr;
  static const String restaurantSummarySeparator = ' · ';
  static String get reservationSelected =>
      'Reservation request selected.'.tr;
  static String get restaurantDetailsSelected =>
      'Restaurant details selected.'.tr;
  static String get openStreetMapContributors =>
      'OpenStreetMap contributors'.tr;

  static String get paymentHistory => 'Payment history'.tr;
  static String get paymentCompleted => 'Completed'.tr;
  static const String paymentDateOne = '18 Jun 2026';
  static const String paymentDateTwo = '02 Jun 2026';
  static const String paymentDateThree = '21 May 2026';
  static const String paymentAmountOne = '£185.00';
  static const String paymentAmountTwo = '£96.00';
  static const String paymentAmountThree = '£142.00';

  static String get browseByOccasion => 'Browse by Occasion'.tr;
  static String get birthday => 'Birthday'.tr;
  static String get anniversary => 'Anniversary'.tr;
  static String get business => 'Business'.tr;
  static String get social => 'Social'.tr;

  static String get hours => 'HOURS'.tr;
  static String get contact => 'CONTACT'.tr;
  static String get leMenu => 'Le Menu'.tr;
  static String get aboutRestaurant => 'ABOUT'.tr;
  static String get amenities => 'AMENITIES'.tr;
  static const String ratingSuffix = ' · ';
  static const String starSymbol = '★';

  static String get dayMonday => 'Monday'.tr;
  static String get dayTuesday => 'Tuesday'.tr;
  static String get dayWednesday => 'Wednesday'.tr;
  static String get dayThursday => 'Thursday'.tr;
  static String get dayFriday => 'Friday'.tr;
  static String get daySaturday => 'Saturday'.tr;
  static String get daySunday => 'Sunday'.tr;
  static String get dayMondayToSaturday =>
      'Monday–Saturday'.tr;
  static String get dayTuesdayToThursday =>
      'Tuesday–Thursday'.tr;
  static String get dayFridayToSaturday =>
      'Friday–Saturday'.tr;
  static String get hoursWeekday => '12:00 PM – 11:00 PM'.tr;
  static String get hoursWeekend => '11:00 AM – 12:00 AM'.tr;
  static String get hoursClosed => 'Closed'.tr;
  static String get hoursLate => '5:00 PM – 1:00 AM'.tr;

  static const String restaurantIdOne = '1';
  static const String restaurantIdTwo = '2';
  static const String restaurantIdThree = '3';
  static const String restaurantIdFour = '4';
  static const String restaurantIdFive = '5';
  static const String restaurantIdSix = '6';

  static const String ratingSaffron = '4.8';
  static const String ratingOtako = '4.9';
  static const String ratingOlive = '4.6';
  static const String ratingGolden = '4.7';
  static const String ratingCedar = '4.5';
  static const String ratingAmber = '4.8';

  static String get locationBlurbSaffron => 'Heart of Old Town'.tr;
  static String get locationBlurbOtako => 'Marina waterfront'.tr;
  static String get locationBlurbOlive =>
      'Garden Street terrace'.tr;
  static String get locationBlurbGolden =>
      'North District loft'.tr;
  static String get locationBlurbCedar =>
      'Elm Avenue corner'.tr;
  static String get locationBlurbAmber => 'Hillview rooftop'.tr;

  static String get aboutSaffron => 'Saffron House is a refined sanctuary of spice and warmth, where chef-led tasting journeys unfold beneath soft amber lighting and hand-carved teak panels.'.tr;
  static String get aboutOtako => 'Otako Sushi celebrates precision and calm — each plate composed with seasonal fish, house-aged soy, and a quiet reverence for Japanese craft.'.tr;
  static String get aboutOlive => 'Olive & Oak blends Mediterranean ease with rustic elegance, serving sunlit plates that feel like a long afternoon by the coast.'.tr;
  static String get aboutGolden => 'Golden Lantern is a contemporary Asian house known for bold textures, lacquered finishes, and tasting menus that feel cinematic.'.tr;
  static String get aboutCedar => 'Cedar Table offers modern comfort dining — polished cuts, hearth-kissed vegetables, and a room designed for lingering conversations.'.tr;
  static String get aboutAmber => 'Amber Terrace is an elevated steakhouse experience with candlelit tables, cellar pours, and panoramic evening views.'.tr;

  static String get amenityValet => 'Valet parking available'.tr;
  static String get amenityPrivateParking =>
      'Private parking on-site'.tr;
  static String get amenityStreetParking =>
      'Street parking nearby'.tr;
  static String get amenityWineCellar => 'Curated wine cellar'.tr;
  static String get amenityPrivateDining =>
      'Private dining rooms'.tr;
  static String get amenityOutdoorTerrace =>
      'Outdoor terrace seating'.tr;
  static String get amenityLiveMusic => 'Live evening music'.tr;
  static String get amenityChefTable =>
      'Chef’s table experiences'.tr;
  static String get amenityWheelchair =>
      'Wheelchair accessible'.tr;
  static String get amenityPetFriendly =>
      'Pet-friendly patio'.tr;
  static String get amenityRooftop => 'Rooftop lounge access'.tr;
  static String get amenityKidsFriendly =>
      'Family-friendly seating'.tr;

  static const String phoneSaffron = '+971 4 528 0194';
  static const String phoneOtako = '+971 4 391 7742';
  static const String phoneOlive = '+971 4 266 8831';
  static const String phoneGolden = '+971 4 745 2290';
  static const String phoneCedar = '+971 4 612 4478';
  static const String phoneAmber = '+971 4 903 1566';

  static String get locationNoteSaffron => 'Nestled along Old Town’s quiet lanes, a short stroll from the heritage square and evening markets.'.tr;
  static String get locationNoteOtako => 'Overlooking Marina Bay, with waterfront access and a serene approach from the promenade.'.tr;
  static String get locationNoteOlive => 'Set on Garden Street beside olive trees and soft courtyard lighting for warm arrivals.'.tr;
  static String get locationNoteGolden => 'Located in North District’s creative loft quarter, easy to reach by metro and rideshare.'.tr;
  static String get locationNoteCedar => 'On Elm Avenue’s dining strip, with valet at the entrance and shaded sidewalk seating.'.tr;
  static String get locationNoteAmber => 'Perched above Hillview, offering elevated city views and a discreet rooftop entrance.'.tr;

  static String get menuSaffronOne => 'Saffron Butter Prawns'.tr;
  static String get menuSaffronOneDesc => 'Gulf prawns finished with saffron butter and citrus leaf.'.tr;
  static const String menuSaffronOnePrice = '£42';
  static String get menuSaffronTwo => 'Tandoor Spiced Lamb'.tr;
  static String get menuSaffronTwoDesc => 'Slow-roasted rack with rose petal glaze and mint oil.'.tr;
  static const String menuSaffronTwoPrice = '£58';
  static String get menuSaffronThree =>
      'Cardamom Rice Pudding'.tr;
  static String get menuSaffronThreeDesc => 'Chilled dessert with pistachio brittle and gold leaf.'.tr;
  static const String menuSaffronThreePrice = '£18';
  static String get menuSaffronFour => 'Mayfair Thali'.tr;
  static String get menuSaffronFourDesc => 'Chef’s tasting selection of seasonal spice plates.'.tr;
  static const String menuSaffronFourPrice = '£74';

  static String get menuOtakoOne => 'Omakase Duo'.tr;
  static String get menuOtakoOneDesc => 'Daily chef selection of nigiri and seasonal garnish.'.tr;
  static const String menuOtakoOnePrice = '£64';
  static String get menuOtakoTwo => 'Torched Wagyu Nigiri'.tr;
  static String get menuOtakoTwoDesc => 'Seared wagyu with truffle soy and crisp shallot.'.tr;
  static const String menuOtakoTwoPrice = '£36';
  static String get menuOtakoThree => 'Yuzu Uni Toast'.tr;
  static String get menuOtakoThreeDesc => 'Warm brioche, sea urchin, and bright yuzu foam.'.tr;
  static const String menuOtakoThreePrice = '£29';
  static String get menuOtakoFour => 'Matcha Soft Serve'.tr;
  static String get menuOtakoFourDesc => 'Ceremonial matcha with black sesame crumble.'.tr;
  static const String menuOtakoFourPrice = '£16';

  static String get menuOliveOne => 'Wood-Fired Mezze'.tr;
  static String get menuOliveOneDesc => 'Hummus, grilled halloumi, and charcoal flatbread.'.tr;
  static const String menuOliveOnePrice = '£28';
  static String get menuOliveTwo => 'Lemon Herb Sea Bass'.tr;
  static String get menuOliveTwoDesc => 'Whole roasted fish with olive oil and garden herbs.'.tr;
  static const String menuOliveTwoPrice = '£49';
  static String get menuOliveThree => 'Fig & Honey Tart'.tr;
  static String get menuOliveThreeDesc => 'Caramelized figs, almond cream, and wild honey.'.tr;
  static const String menuOliveThreePrice = '£17';
  static String get menuOliveFour => 'Coastal Salad'.tr;
  static String get menuOliveFourDesc => 'Fennel, citrus, and toasted pine nuts.'.tr;
  static const String menuOliveFourPrice = '£22';

  static String get menuGoldenOne => 'Lacquered Duck'.tr;
  static String get menuGoldenOneDesc => 'Crisp duck with five-spice glaze and pickled plum.'.tr;
  static const String menuGoldenOnePrice = '£54';
  static String get menuGoldenTwo => 'Silk Broth Dumplings'.tr;
  static String get menuGoldenTwoDesc => 'Hand-folded dumplings in aromatic consommé.'.tr;
  static const String menuGoldenTwoPrice = '£31';
  static String get menuGoldenThree => 'Charcoal Aubergine'.tr;
  static String get menuGoldenThreeDesc => 'Smoked aubergine with miso butter and sesame.'.tr;
  static const String menuGoldenThreePrice = '£24';
  static String get menuGoldenFour => 'Black Sesame Mousse'.tr;
  static String get menuGoldenFourDesc => 'Silky mousse with cherry gel and crisp tuile.'.tr;
  static const String menuGoldenFourPrice = '£19';

  static String get menuCedarOne => 'Cedar-Smoked Steak'.tr;
  static String get menuCedarOneDesc => 'Dry-aged cut finished over cedar smoke.'.tr;
  static const String menuCedarOnePrice = '£68';
  static String get menuCedarTwo =>
      'Butter-Poached Lobster'.tr;
  static String get menuCedarTwoDesc => 'Gentle lobster with herb beurre blanc.'.tr;
  static const String menuCedarTwoPrice = '£72';
  static String get menuCedarThree => 'Roasted Root Bowl'.tr;
  static String get menuCedarThreeDesc => 'Seasonal roots, hazelnut butter, and thyme.'.tr;
  static const String menuCedarThreePrice = '£26';
  static String get menuCedarFour =>
      'Vanilla Bean Panna Cotta'.tr;
  static String get menuCedarFourDesc => 'Soft set cream with berry reduction.'.tr;
  static const String menuCedarFourPrice = '£15';

  static String get menuAmberOne => 'Amber Ribeye'.tr;
  static String get menuAmberOneDesc => 'Prime ribeye with bone marrow butter.'.tr;
  static const String menuAmberOnePrice = '£76';
  static String get menuAmberTwo => 'Truffle Fries'.tr;
  static String get menuAmberTwoDesc => 'Crisp fries finished with aged parmesan.'.tr;
  static const String menuAmberTwoPrice = '£18';
  static String get menuAmberThree => 'Ember Salad'.tr;
  static String get menuAmberThreeDesc => 'Charred greens with citrus vinaigrette.'.tr;
  static const String menuAmberThreePrice = '£21';
  static String get menuAmberFour =>
      'Dark Chocolate Soufflé'.tr;
  static String get menuAmberFourDesc => 'Warm soufflé with salted caramel cream.'.tr;
  static const String menuAmberFourPrice = '£20';
}
