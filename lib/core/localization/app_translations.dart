import 'package:get/get.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {'en': _en, 'ar': _ar};

  /// Resolves API label variants to a canonical English translation key.
  static String resolveUiLabelKey(String raw) {
    final String trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return raw;
    }
    if (_en.containsKey(trimmed)) {
      return trimmed;
    }

    final String lower = trimmed.toLowerCase();
    final String spaced = trimmed.replaceAll(RegExp(r'[_-]+'), ' ').trim();
    final String spacedLower = spaced.toLowerCase();
    final String titled = _titleCaseWords(spaced);

    for (final String key in _en.keys) {
      if (key.length > 40 || key.contains('.')) {
        continue;
      }
      final String keyLower = key.toLowerCase();
      if (keyLower == lower || keyLower == spacedLower) {
        return key;
      }
    }

    if (_en.containsKey(titled)) {
      return titled;
    }
    return titled;
  }

  static bool hasUiLabelTranslation(String key) {
    return _en.containsKey(key) || _ar.containsKey(key);
  }

  static String _titleCaseWords(String value) {
    if (value.isEmpty) {
      return value;
    }
    return value
        .split(RegExp(r'\s+'))
        .map((String word) {
          if (word.isEmpty) {
            return word;
          }
          final String upper = word.toUpperCase();
          if (word.length <= 3 && word == upper) {
            return upper;
          }
          // Prefer known acronyms stored in uppercase in translations (BBQ).
          if (word.length <= 3 && _en.containsKey(upper)) {
            return upper;
          }
          return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
        })
        .join(' ');
  }

  static const Map<String, String> _en = {
    'Business Lunch': 'Business Lunch',
    'Casual': 'Casual',
    'Cancelled': 'Cancelled',
    'Changing language': 'Changing language',
    'Could not load map restaurants. Showing available pins.':
        'Could not load map restaurants. Showing available pins.',
    'Could not get your location. Please try again.':
        'Could not get your location. Please try again.',
    'Date Night': 'Date Night',
    'European': 'European',
    'Fine Dining': 'Fine Dining',
    'Fusion': 'Fusion',
    'Gathering': 'Gathering',
    'Group Gathering': 'Group Gathering',
    'Korean': 'Korean',
    'Launch Business': 'Launch Business',
    'Lunch Business': 'Lunch Business',
    'Moroccan': 'Moroccan',
    'Persian': 'Persian',
    'Romantic': 'Romantic',
    'Steak': 'Steak',
    'Turkish': 'Turkish',
    'Updating your dining experience': 'Updating your dining experience',
    ' SEATS': ' SEATS',
    '07:30 PM': '07:30 PM',
    '08:00 PM': '08:00 PM',
    '08:30 PM': '08:30 PM',
    '09:15 PM': '09:15 PM',
    '1.5 H': '1.5 H',
    '11:00 AM – 12:00 AM': '11:00 AM – 12:00 AM',
    '12 Jul': '12 Jul',
    '120 pts': '120 pts',
    '12:00 PM – 11:00 PM': '12:00 PM – 11:00 PM',
    '2 Guests': '2 Guests',
    '2 H': '2 H',
    '2.5 H': '2.5 H',
    '380 points remaining': '380 points remaining',
    '5:00 PM – 1:00 AM': '5:00 PM – 1:00 AM',
    'ABOUT': 'ABOUT',
    'Active always': 'Active always',
    'Active dining placements': 'Active dining placements',
    'All Restaurants': 'All Restaurants',
    'Always ready': 'Always ready',
    'AM': 'AM',
    'Amber Ribeye': 'Amber Ribeye',
    'Amber Terrace is an elevated steakhouse experience with candlelit tables, cellar pours, and panoramic evening views.':
        'Amber Terrace is an elevated steakhouse experience with candlelit tables, cellar pours, and panoramic evening views.',
    'Amber Terrace · Hillview': 'Amber Terrace · Hillview',
    'AMENITIES': 'AMENITIES',
    'American': 'American',
    'Anniversary': 'Anniversary',
    'April': 'April',
    'Approved': 'Approved',
    'Arabic': 'Arabic',
    'Asian': 'Asian',
    'Ask Tavola AI for a recommendation...':
        'Ask Tavola AI for a recommendation...',
    'AUG': 'AUG',
    'August': 'August',
    'AVAILABLE': 'AVAILABLE',
    'AVAILABLE TIME SLOTS': 'AVAILABLE TIME SLOTS',
    'BBQ': 'BBQ',
    'Being refreshed for the next service. This table will be ready shortly.':
        'Being refreshed for the next service. This table will be ready shortly.',
    'Birthday': 'Birthday',
    'Birthday tasting gift': 'Birthday tasting gift',
    'Black Sesame Mousse': 'Black Sesame Mousse',
    'BOOK IN A FEW TAPS': 'BOOK IN A FEW TAPS',
    'Book a table': 'Book a table',
    'Book now': 'Book now',
    'Booked': 'Booked',
    'Booking': 'Booking',
    'Browse by Occasion': 'Browse by Occasion',
    'Brunch': 'Brunch',
    'Business': 'Business',
    'Butter-Poached Lobster': 'Butter-Poached Lobster',
    'Cafe': 'Cafe',
    'Call': 'Call',
    'Cancel': 'Cancel',
    'Caramelized figs, almond cream, and wild honey.':
        'Caramelized figs, almond cream, and wild honey.',
    'Cardamom Rice Pudding': 'Cardamom Rice Pudding',
    'Cedar Table offers modern comfort dining — polished cuts, hearth-kissed vegetables, and a room designed for lingering conversations.':
        'Cedar Table offers modern comfort dining — polished cuts, hearth-kissed vegetables, and a room designed for lingering conversations.',
    'Cedar Table · Mayfair': 'Cedar Table · Mayfair',
    'Cedar-Smoked Steak': 'Cedar-Smoked Steak',
    'Celebration': 'Celebration',
    'Ceremonial matcha with black sesame crumble.':
        'Ceremonial matcha with black sesame crumble.',
    'Change date': 'Change date',
    'Charcoal Aubergine': 'Charcoal Aubergine',
    'Charred greens with citrus vinaigrette.':
        'Charred greens with citrus vinaigrette.',
    'Chat': 'Chat',
    'Sign in to message your dining host.':
        'Sign in to message your dining host.',
    'No conversations yet. Start one with a restaurant.':
        'No conversations yet. Start one with a restaurant.',
    'Could not load conversations. Please try again.':
        'Could not load conversations. Please try again.',
    'Could not load messages. Please try again.':
        'Could not load messages. Please try again.',
    'Could not send your message. Please try again.':
        'Could not send your message. Please try again.',
    'Could not start the conversation. Please try again.':
        'Could not start the conversation. Please try again.',
    'Could not close the conversation. Please try again.':
        'Could not close the conversation. Please try again.',
    'Start conversation': 'Start conversation',
    'Choose a restaurant': 'Choose a restaurant',
    'Close chat': 'Close chat',
    'All chats': 'All chats',
    'This conversation is closed.': 'This conversation is closed.',
    'You can start a new chat with another restaurant anytime.':
        'You can start a new chat with another restaurant anytime.',
    'Chat with another restaurant': 'Chat with another restaurant',
    'Invalid conversation payload.': 'Invalid conversation payload.',
    'Invalid message payload.': 'Invalid message payload.',
    'CHECK YOUR WHATSAPP': 'CHECK YOUR WHATSAPP',
    'Chef’s table experiences': 'Chef’s table experiences',
    'Chef’s tasting selection of seasonal spice plates.':
        'Chef’s tasting selection of seasonal spice plates.',
    'Chilled dessert with pistachio brittle and gold leaf.':
        'Chilled dessert with pistachio brittle and gold leaf.',
    'Chinese': 'Chinese',
    'Choose your dining destination to begin crafting a refined reservation experience.':
        'Choose your dining destination to begin crafting a refined reservation experience.',
    'Choose your table and preferred seating to craft a refined dining experience.':
        'Choose your table and preferred seating to craft a refined dining experience.',
    'CLEANING': 'CLEANING',
    'Closed': 'Closed',
    'Vietnamese': 'Vietnamese',
    'Wedding': 'Wedding',
    '—': '—',
    'Restaurant details unavailable.': 'Restaurant details unavailable.',
    'Could not load restaurant details.': 'Could not load restaurant details.',
    'Coastal Salad': 'Coastal Salad',
    'Comfort-forward plates and perfect steak .':
        'Comfort-forward plates and perfect steak .',
    'Compact table being reset after lunch service — available again shortly.':
        'Compact table being reset after lunch service — available again shortly.',
    'Completed': 'Completed',
    'Complimentary amuse-bouche': 'Complimentary amuse-bouche',
    'Concierge': 'Concierge',
    'Concierge Screen': 'Concierge Screen',
    'Confirm': 'Confirm',
    'CONFIRM RESERVATION': 'CONFIRM RESERVATION',
    'Confirm your password': 'Confirm your password',
    'Confirmation Code': 'Confirmation Code',
    'Confirmed': 'Confirmed',
    'CONTACT': 'CONTACT',
    'Contemporary': 'Contemporary',
    'Corporate': 'Corporate',
    'CONTINUE AS GUEST': 'CONTINUE AS GUEST',
    'Corner booth reserved for a birthday celebration — unavailable for new bookings.':
        'Corner booth reserved for a birthday celebration — unavailable for new bookings.',
    'Cozy corner table with soft ambient lighting — ideal for relaxed conversations.':
        'Cozy corner table with soft ambient lighting — ideal for relaxed conversations.',
    'Create password': 'Create password',
    'Choose a password for your account.':
        'Choose a password for your account.',
    'Enter your username and phone number to start reserving tables.':
        'Enter your username and phone number to start reserving tables.',
    'Crisp duck with five-spice glaze and pickled plum.':
        'Crisp duck with five-spice glaze and pickled plum.',
    'Crisp fries finished with aged parmesan.':
        'Crisp fries finished with aged parmesan.',
    'Cuisines': 'Cuisines',
    'Curated wine cellar': 'Curated wine cellar',
    'Currently held for an arriving party. Please choose another available table.':
        'Currently held for an arriving party. Please choose another available table.',
    'Daily chef selection of nigiri and seasonal garnish.':
        'Daily chef selection of nigiri and seasonal garnish.',
    'Dark Chocolate Soufflé': 'Dark Chocolate Soufflé',
    'DATE': 'DATE',
    'Date': 'Date',
    'December': 'December',
    'Details': 'Details',
    'Details Screen': 'Details Screen',
    'DINE AND EARN': 'DINE AND EARN',
    'DINING': 'DINING',
    'Dinner': 'Dinner',
    'Directions': 'Directions',
    'DISMISS': 'DISMISS',
    'Drag and pinch to explore the dining room':
        'Drag and pinch to explore the dining room',
    'Dry-aged cut finished over cedar smoke.':
        'Dry-aged cut finished over cedar smoke.',
    'Early access to peak tables': 'Early access to peak tables',
    'Earn points with every reservation and unlock refined dining privileges.':
        'Earn points with every reservation and unlock refined dining privileges.',
    'Elegant dining experience with refined spice blends.':
        'Elegant dining experience with refined spice blends.',
    'Elm Avenue': 'Elm Avenue',
    'Elm Avenue corner': 'Elm Avenue corner',
    'Ember Salad': 'Ember Salad',
    'Emirati': 'Emirati',
    'English': 'English',
    'Enjoy a premium dinner experience with chef-selected flavors and a warm atmosphere.':
        'Enjoy a premium dinner experience with chef-selected flavors and a warm atmosphere.',
    'Could not load offers. Please try again.':
        'Could not load offers. Please try again.',
    'No special offers available right now.':
        'No special offers available right now.',
    'Invalid offer payload.': 'Invalid offer payload.',
    'Account created. Please log in.': 'Account created. Please log in.',
    'Password updated. Please log in.': 'Password updated. Please log in.',
    'This username is already taken. Please choose a different username.':
        'This username is already taken. Please choose a different username.',
    'This phone number already has an account. Log in or use another number.':
        'This phone number already has an account. Log in or use another number.',
    'This username is taken, and this phone number already has an account. Please change them or log in.':
        'This username is taken, and this phone number already has an account. Please change them or log in.',
    'Choose a new password for your account.':
        'Choose a new password for your account.',
    'Enter new password': 'Enter new password',
    'Reset password': 'Reset password',
    'Enter at least @count digits.': 'Enter at least @count digits.',
    'Enter a valid phone number for the selected country.':
        'Enter a valid phone number for the selected country.',
    'Enter the verification code we sent you.':
        'Enter the verification code we sent you.',
    'Enter your name': 'Enter your name',
    'Enter your name.': 'Enter your name.',
    'Enter your number': 'Enter your number',
    'Enter your password': 'Enter your password',
    'Enter your username': 'Enter your username',
    'Enter your username.': 'Enter your username.',
    'ENTRANCE': 'ENTRANCE',
    'EXAMPLE': 'EXAMPLE',
    'Exclusive Offers': 'Exclusive Offers',
    'EXPERIENCE DURATION': 'EXPERIENCE DURATION',
    'Explore': 'Explore',
    'Explore more restaurants': 'Explore more restaurants',
    'Explore the dining room, choose an available table, and confirm your placement.':
        'Explore the dining room, choose an available table, and confirm your placement.',
    'EXPLORE THE GILDED OLIVE': 'EXPLORE THE GILDED OLIVE',
    'Family-friendly seating': 'Family-friendly seating',
    'Family': 'Family',
    'Favorite': 'Favorite',
    'Favorite Cuisines': 'Favorite Cuisines',
    'Favorite dining selections': 'Favorite dining selections',
    'Favorites': 'Favorites',
    'Favorites Screen': 'Favorites Screen',
    'February': 'February',
    'Fennel, citrus, and toasted pine nuts.':
        'Fennel, citrus, and toasted pine nuts.',
    'Fig & Honey Tart': 'Fig & Honey Tart',
    'Find me an intimate table for two tonight.':
        'Find me an intimate table for two tonight.',
    'Fine System Configurations': 'Fine System Configurations',
    'FLOOR PLAN': 'FLOOR PLAN',
    'Forgot password?': 'Forgot password?',
    'French': 'French',
    'Friends': 'Friends',
    'FRI': 'FRI',
    'Fri, 19 Aug': 'Fri, 19 Aug',
    'Fri, 19 Aug · 8:00 PM': 'Fri, 19 Aug · 8:00 PM',
    'Friday': 'Friday',
    'Friday–Saturday': 'Friday–Saturday',
    'Garden Street': 'Garden Street',
    'Garden Street terrace': 'Garden Street terrace',
    'Gentle lobster with herb beurre blanc.':
        'Gentle lobster with herb beurre blanc.',
    'GET STARTED': 'GET STARTED',
    'Golden Lantern is a contemporary Asian house known for bold textures, lacquered finishes, and tasting menus that feel cinematic.':
        'Golden Lantern is a contemporary Asian house known for bold textures, lacquered finishes, and tasting menus that feel cinematic.',
    'Good afternoon. I am your TAVOLA Concierge. I can guide you through premium seating, suggest perfect wine pairings, or coordinate an exquisite table reservation at any of our Mayfair partners.':
        'Good afternoon. I am your TAVOLA Concierge. I can guide you through premium seating, suggest perfect wine pairings, or coordinate an exquisite table reservation at any of our Mayfair partners.',
    'Greek': 'Greek',
    'Guest': 'Guest',
    'GUESTS': 'GUESTS',
    'Guests': 'Guests',
    'guest_plural': 'Guests',
    'Gulf prawns finished with saffron butter and citrus leaf.':
        'Gulf prawns finished with saffron butter and citrus leaf.',
    'Hand-folded dumplings in aromatic consommé.':
        'Hand-folded dumplings in aromatic consommé.',
    'Heart of Old Town': 'Heart of Old Town',
    'Hillview': 'Hillview',
    'Hillview rooftop': 'Hillview rooftop',
    'Home': 'Home',
    'Host Member': 'Host Member',
    'HOURS': 'HOURS',
    'Hours unavailable.': 'Hours unavailable.',
    'Hummus, grilled halloumi, and charcoal flatbread.':
        'Hummus, grilled halloumi, and charcoal flatbread.',
    'Indian': 'Indian',
    'Intimate two-seat table near the host stand, perfect for a quiet dinner.':
        'Intimate two-seat table near the host stand, perfect for a quiet dinner.',
    'Invitations for special Mayfair cellar wine pairings':
        'Invitations for special Mayfair cellar wine pairings',
    'Invite friends': 'Invite friends',
    'Italian': 'Italian',
    'January': 'January',
    'Japanese': 'Japanese',
    'Japanese · Sushi': 'Japanese · Sushi',
    'July': 'July',
    'June': 'June',
    'Lacquered Duck': 'Lacquered Duck',
    'Language': 'Language',
    'Large party table reserved for a corporate dinner event this evening.':
        'Large party table reserved for a corporate dinner event this evening.',
    'Late Arrival Automatically Inform': 'Late Arrival Automatically Inform',
    'Late seating priority': 'Late seating priority',
    'Le Menu': 'Le Menu',
    'Lebanese': 'Lebanese',
    'Lemon Herb Sea Bass': 'Lemon Herb Sea Bass',
    'Let hosts know you are delayed via dynamic chat dispatches':
        'Let hosts know you are delayed via dynamic chat dispatches',
    'Limited': 'Limited',
    'Live alert when hostess prepares physical placement':
        'Live alert when hostess prepares physical placement',
    'Live availability, instant booking, and smart reminders.':
        'Live availability, instant booking, and smart reminders.',
    'Live evening music': 'Live evening music',
    'Located in North District’s creative loft quarter, easy to reach by metro and rideshare.':
        'Located in North District’s creative loft quarter, easy to reach by metro and rideshare.',
    'LOGIN': 'LOGIN',
    'LOGIN / SIGN UP': 'LOGIN / SIGN UP',
    'Login with your phone number and password':
        'Login with your phone number and password',
    'Enter your email': 'Enter your email',
    'Enter a valid email address.': 'Enter a valid email address.',
    'Log out': 'Log out',
    'Lunch': 'Lunch',
    'Make it a group experience! (Optional)':
        'Make it a group experience! (Optional)',
    'Manage details, share your code, and reach your host in one place.':
        'Manage details, share your code, and reach your host in one place.',
    'Map': 'Map',
    'March': 'March',
    'Marina Bay': 'Marina Bay',
    'Marina waterfront': 'Marina waterfront',
    'Matcha Soft Serve': 'Matcha Soft Serve',
    'May': 'May',
    'Mayfair Thali': 'Mayfair Thali',
    'Mediterranean': 'Mediterranean',
    'Member Privileges': 'Member Privileges',
    'Menu': 'Menu',
    'Burrata Caprese': 'Burrata Caprese',
    'Creamy burrata with heirloom tomatoes and basil oil.':
        'Creamy burrata with heirloom tomatoes and basil oil.',
    'Crispy Calamari': 'Crispy Calamari',
    'Lightly fried squid with lemon aioli and chili salt.':
        'Lightly fried squid with lemon aioli and chili salt.',
    'Mushroom Risotto': 'Mushroom Risotto',
    'Arborio rice with wild mushrooms and aged parmesan.':
        'Arborio rice with wild mushrooms and aged parmesan.',
    'Grilled Octopus': 'Grilled Octopus',
    'Charred octopus with smoked paprika and olive salsa.':
        'Charred octopus with smoked paprika and olive salsa.',
    'Beef Tartare': 'Beef Tartare',
    'Hand-cut beef with quail egg, capers, and toasted brioche.':
        'Hand-cut beef with quail egg, capers, and toasted brioche.',
    'Lobster Mac': 'Lobster Mac',
    'Baked macaroni with lobster, gruyère, and herb crumb.':
        'Baked macaroni with lobster, gruyère, and herb crumb.',
    'Seared Scallops': 'Seared Scallops',
    'Caramelized scallops with cauliflower purée and brown butter.':
        'Caramelized scallops with cauliflower purée and brown butter.',
    'Lamb Kofta': 'Lamb Kofta',
    'Spiced lamb skewers with mint yogurt and flatbread.':
        'Spiced lamb skewers with mint yogurt and flatbread.',
    'Prawn Linguine': 'Prawn Linguine',
    'Fresh linguine with garlic prawns and chili oil.':
        'Fresh linguine with garlic prawns and chili oil.',
    'Duck Confit': 'Duck Confit',
    'Slow-cooked duck leg with orange glaze and greens.':
        'Slow-cooked duck leg with orange glaze and greens.',
    'Tiramisu': 'Tiramisu',
    'Classic espresso tiramisu with mascarpone cream.':
        'Classic espresso tiramisu with mascarpone cream.',
    'Citrus Panna Cotta': 'Citrus Panna Cotta',
    'Vanilla panna cotta with blood-orange syrup.':
        'Vanilla panna cotta with blood-orange syrup.',
    'Message your dining host...': 'Message your dining host...',
    'Mexican': 'Mexican',
    'Modern tasting menu with signature pours.':
        'Modern tasting menu with signature pours.',
    'Monday': 'Monday',
    'Monday–Saturday': 'Monday–Saturday',
    'Enable location for nearby restaurants':
        'Enable location for nearby restaurants',
    'Enable': 'Enable',
    'Finding your location…': 'Finding your location…',
    'Location permission is required for nearby recommendations.':
        'Location permission is required for nearby recommendations.',
    'Location access is blocked. Open Settings to enable it.':
        'Location access is blocked. Open Settings to enable it.',
    'Location access is restricted on this device.':
        'Location access is restricted on this device.',
    'Turn on Location Services to see nearby restaurants.':
        'Turn on Location Services to see nearby restaurants.',
    'Open Settings': 'Open Settings',
    'Open Location Settings': 'Open Location Settings',
    'Your location is currently unavailable.':
        'Your location is currently unavailable.',
    'Near you': 'Near you',
    'NEAR DUBAI, JBR': 'NEAR DUBAI, JBR',
    'Need 60 more points': 'Need 60 more points',
    'Nestled along Old Town’s quiet lanes, a short stroll from the heritage square and evening markets.':
        'Nestled along Old Town’s quiet lanes, a short stroll from the heritage square and evening markets.',
    'NEXT : SELECT TABLE': 'NEXT : SELECT TABLE',
    'NEXT: SILVER HOST': 'NEXT: SILVER HOST',
    'North District': 'North District',
    'North District loft': 'North District loft',
    'No cuisine categories available.': 'No cuisine categories available.',
    'No occasion categories available.': 'No occasion categories available.',
    'No restaurants available.': 'No restaurants available.',
    'Restaurant catalog is not available for customer accounts on this API yet.':
        'Restaurant catalog is not available for customer accounts on this API yet.',
    'Restaurant API is not yet available.':
        'Restaurant API is not yet available.',
    'No tables available.': 'No tables available.',
    'No branch is available for this restaurant.':
        'No branch is available for this restaurant.',
    'No floor plan is available for this restaurant.':
        'No floor plan is available for this restaurant.',
    'Notifications': 'Notifications',
    'No notifications yet.': 'No notifications yet.',
    'Mark all read': 'Mark all read',
    '99+': '99+',
    'Sign in to view your notifications.':
        'Sign in to view your notifications.',
    'Invalid notification payload.': 'Invalid notification payload.',
    'Join waitlist': 'Join waitlist',
    'You are on the waitlist. We will notify you when a table opens.':
        'You are on the waitlist. We will notify you when a table opens.',
    'Could not join the waitlist. Please try again.':
        'Could not join the waitlist. Please try again.',
    'Leave waitlist': 'Leave waitlist',
    'You have left the waitlist.': 'You have left the waitlist.',
    'Could not leave the waitlist. Please try again.':
        'Could not leave the waitlist. Please try again.',
    'Invalid waitlist payload.': 'Invalid waitlist payload.',
    'Invalid restaurant payload.': 'Invalid restaurant payload.',
    'Invalid branch payload.': 'Invalid branch payload.',
    'Invalid table payload.': 'Invalid table payload.',
    'Invalid reservation payload.': 'Invalid reservation payload.',
    'Could not create reservation. Please try again.':
        'Could not create reservation. Please try again.',
    'Could not load table availability. Please try again.':
        'Could not load table availability. Please try again.',
    'Could not load reservations. Please try again.':
        'Could not load reservations. Please try again.',
    'Could not load your reviews.': 'Could not load your reviews.',
    'Could not load the menu. Please try again.':
        'Could not load the menu. Please try again.',
    'Could not submit your review.': 'Could not submit your review.',
    'Could not remove your review.': 'Could not remove your review.',
    'Choose a rating from 1 to 5.': 'Choose a rating from 1 to 5.',
    'Invalid review payload.': 'Invalid review payload.',
    'Invalid review rating.': 'Invalid review rating.',
    'No menu items available.': 'No menu items available.',
    'Invalid menu payload.': 'Invalid menu payload.',
    'Choose a date, time, and party size before selecting a table.':
        'Choose a date, time, and party size before selecting a table.',
    'Invalid user profile payload.': 'Invalid user profile payload.',
    'Invalid user preferences payload.': 'Invalid user preferences payload.',
    'No profile available.': 'No profile available.',
    'No reservations yet': 'No reservations yet',
    'Your upcoming tables will appear here — reserve a place and return for a refined overview of every seating.':
        'Your upcoming tables will appear here — reserve a place and return for a refined overview of every seating.',
    'Could not upload avatar. Please try again.':
        'Could not upload avatar. Please try again.',
    'Could not update preferences. Please try again.':
        'Could not update preferences. Please try again.',
    'Could not update profile. Please try again.':
        'Could not update profile. Please try again.',
    'Change photo': 'Change photo',
    'Account details': 'Account details',
    'First name': 'First name',
    'Last name': 'Last name',
    'Phone': 'Phone',
    'Preferred currency': 'Preferred currency',
    'Save changes': 'Save changes',
    'Profile updated.': 'Profile updated.',
    'Reservation notifications': 'Reservation notifications',
    'Receive reminders and updates about your reservations.':
        'Receive reminders and updates about your reservations.',
    'Marketing & promotions': 'Marketing & promotions',
    'Receive offers, events, and concierge invitations.':
        'Receive offers, events, and concierge invitations.',
    'Cancel reservation': 'Cancel reservation',
    'Reschedule': 'Reschedule',
    'Are you sure?': 'Are you sure?',
    'Yes': 'Yes',
    'No': 'No',
    'Cancel this reservation?': 'Cancel this reservation?',
    'Reschedule this reservation?': 'Reschedule this reservation?',
    'Log out of your account?': 'Log out of your account?',
    'Not finding a place to eat? Ask Tavola AI':
        'Not finding a place to eat? Ask Tavola AI',
    'November': 'November',
    'NOWTIME': 'NOWTIME',
    'NUMBER OF DINERS': 'NUMBER OF DINERS',
    'Occasions': 'Occasions',
    'October': 'October',
    'Old Town': 'Old Town',
    'Olive & Oak blends Mediterranean ease with rustic elegance, serving sunlit plates that feel like a long afternoon by the coast.':
        'Olive & Oak blends Mediterranean ease with rustic elegance, serving sunlit plates that feel like a long afternoon by the coast.',
    'Olive & Oak has a quiet window table at 8:30 PM — soft lighting and garden views.':
        'Olive & Oak has a quiet window table at 8:30 PM — soft lighting and garden views.',
    'Omakase Duo': 'Omakase Duo',
    'On Elm Avenue’s dining strip, with valet at the entrance and shaded sidewalk seating.':
        'On Elm Avenue’s dining strip, with valet at the entrance and shaded sidewalk seating.',
    'Open': 'Open',
    'Open now': 'Open now',
    'OpenStreetMap contributors': 'OpenStreetMap contributors',
    'CARTO': 'CARTO',
    'OpenStreetMap · CARTO': 'OpenStreetMap · CARTO',
    'Otako Sushi celebrates precision and calm — each plate composed with seasonal fish, house-aged soy, and a quiet reverence for Japanese craft.':
        'Otako Sushi celebrates precision and calm — each plate composed with seasonal fish, house-aged soy, and a quiet reverence for Japanese craft.',
    'Outdoor terrace seating': 'Outdoor terrace seating',
    'Overlooking Marina Bay, with waterfront access and a serene approach from the promenade.':
        'Overlooking Marina Bay, with waterfront access and a serene approach from the promenade.',
    'Passwords do not match.': 'Passwords do not match.',
    'Last Reservations': 'Last Reservations',
    'Payment history': 'Payment history',
    'Payments': 'Payments',
    'Pending': 'Pending',
    'Rate your visit': 'Rate your visit',
    'Your review': 'Your review',
    'Write a review': 'Write a review',
    'Submit review': 'Submit review',
    'Share a few words about your evening.':
        'Share a few words about your evening.',
    'Review submitted successfully.': 'Review submitted successfully.',
    'Review removed.': 'Review removed.',
    'Remove this review? This cannot be undone.':
        'Remove this review? This cannot be undone.',
    'Remove review': 'Remove review',
    'Add photo': 'Add photo',
    'Optional photo': 'Optional photo',
    'Tap a star to rate': 'Tap a star to rate',
    'Reservation history': 'Reservation history',
    'Perched above Hillview, offering elevated city views and a discreet rooftop entrance.':
        'Perched above Hillview, offering elevated city views and a discreet rooftop entrance.',
    'Pet-friendly patio': 'Pet-friendly patio',
    'Please select an available table to continue.':
        'Please select an available table to continue.',
    'PM': 'PM',
    'Points': 'Points',
    'Preferred time': 'Preferred time',
    'Premium cuts and candlelit evenings.':
        'Premium cuts and candlelit evenings.',
    'Premium window seating with panoramic city views, natural daylight, and a quiet atmosphere — ideal for intimate dining and special occasions.':
        'Premium window seating with panoramic city views, natural daylight, and a quiet atmosphere — ideal for intimate dining and special occasions.',
    'Preview the floor plan and pick your favorite seat.':
        'Preview the floor plan and pick your favorite seat.',
    'Prime ribeye with bone marrow butter.':
        'Prime ribeye with bone marrow butter.',
    'Private dining rooms': 'Private dining rooms',
    'Private parking on-site': 'Private parking on-site',
    'Profile': 'Profile',
    'Promotions & Concierge Events': 'Promotions & Concierge Events',
    'QR CODE': 'QR CODE',
    'Quick actions': 'Quick actions',
    'Ready': 'Ready',
    'Receive 2-hour arrival warnings and hosts updates':
        'Receive 2-hour arrival warnings and hosts updates',
    'Redeemed': 'Redeemed',
    'REFERENCE : ': 'REFERENCE : ',
    'RESEND IT': 'RESEND IT',
    'Reservation': 'Reservation',
    'Reservation Preferences': 'Reservation Preferences',
    'Reservation Reminder Notifications': 'Reservation Reminder Notifications',
    'Reservation request selected.': 'Reservation request selected.',
    'Reservation Screen': 'Reservation Screen',
    'Reservation summary': 'Reservation summary',
    'Reservations': 'Reservations',
    'Reserve Table': 'Reserve Table',
    'RESERVED': 'RESERVED',
    'Retry': 'Retry',
    'RESTAURANT': 'RESTAURANT',
    'Restaurant details selected.': 'Restaurant details selected.',
    'Restaurants near you': 'Restaurants near you',
    'Roasted Root Bowl': 'Roasted Root Bowl',
    'Rooftop lounge access': 'Rooftop lounge access',
    'Saffron Butter Prawns': 'Saffron Butter Prawns',
    'Saffron House is a refined sanctuary of spice and warmth, where chef-led tasting journeys unfold beneath soft amber lighting and hand-carved teak panels.':
        'Saffron House is a refined sanctuary of spice and warmth, where chef-led tasting journeys unfold beneath soft amber lighting and hand-carved teak panels.',
    'SAT': 'SAT',
    'Saturday': 'Saturday',
    'Save': 'Save',
    'Saved': 'Saved',
    'Something went wrong. Please try again.':
        'Something went wrong. Please try again.',
    'Unable to connect. Check your internet connection.':
        'Unable to connect. Check your internet connection.',
    'The request timed out. Please try again.':
        'The request timed out. Please try again.',
    'Your session has expired. Please sign in again.':
        'Your session has expired. Please sign in again.',
    'Please sign in to continue.': 'Please sign in to continue.',
    'Invalid phone or password. Please try again.':
        'Invalid phone or password. Please try again.',
    'You do not have permission to perform this action.':
        'You do not have permission to perform this action.',
    'The requested resource was not found.':
        'The requested resource was not found.',
    'Too many attempts. Please wait and try again.':
        'Too many attempts. Please wait and try again.',
    'Invalid authentication session payload.':
        'Invalid authentication session payload.',
    'Invalid registration response.': 'Invalid registration response.',
    'Your session could not be refreshed. Please sign in again.':
        'Your session could not be refreshed. Please sign in again.',
    'The server is unavailable right now.':
        'The server is unavailable right now.',
    'Seafood': 'Seafood',
    'Search country': 'Search country',
    'Search restaurants': 'Search restaurants',
    'Search Resturant': 'Search Resturant',
    'Seared wagyu with truffle soy and crisp shallot.':
        'Seared wagyu with truffle soy and crisp shallot.',
    'Seasonal plates with warm, rustic charm.':
        'Seasonal plates with warm, rustic charm.',
    'Seasonal roots, hazelnut butter, and thyme.':
        'Seasonal roots, hazelnut butter, and thyme.',
    'SELECT DATE': 'SELECT DATE',
    'Select the cuisines you enjoy the most to get personalized recommendations.':
        'Select the cuisines you enjoy the most to get personalized recommendations.',
    'Select your restaurant': 'Select your restaurant',
    'Select your table': 'Select your table',
    'SELECTED': 'SELECTED',
    'SELECTED TABLE': 'SELECTED TABLE',
    'September': 'September',
    'SERVICE': 'SERVICE',
    'Set on Garden Street beside olive trees and soft courtyard lighting for warm arrivals.':
        'Set on Garden Street beside olive trees and soft courtyard lighting for warm arrivals.',
    'Settings': 'Settings',
    'Settings Screen': 'Settings Screen',
    'SIGN IN': 'SIGN IN',
    'SIGN UP': 'SIGN UP',
    'Silk Broth Dumplings': 'Silk Broth Dumplings',
    'Silky mousse with cherry gel and crisp tuile.':
        'Silky mousse with cherry gel and crisp tuile.',
    'Skip for Now': 'Skip for Now',
    'Slow-roasted rack with rose petal glaze and mint oil.':
        'Slow-roasted rack with rose petal glaze and mint oil.',
    'Smoked aubergine with miso butter and sesame.':
        'Smoked aubergine with miso butter and sesame.',
    'Social': 'Social',
    'Soft set cream with berry reduction.':
        'Soft set cream with berry reduction.',
    'Spacious booth with lounge seating and generous space for larger gatherings.':
        'Spacious booth with lounge seating and generous space for larger gatherings.',
    'Spanish': 'Spanish',
    'Special Offer': 'Special Offer',
    'STATUS': 'STATUS',
    'STAY IN CONTROL': 'STAY IN CONTROL',
    'Steakhouse': 'Steakhouse',
    'Vegetarian': 'Vegetarian',
    'Street parking nearby': 'Street parking nearby',
    'Sunday': 'Sunday',
    'Sushi': 'Sushi',
    'Sushi by a special chief.': 'Sushi by a special chief.',
    'SWIPE TO EXPLORE': 'SWIPE TO EXPLORE',
    'Switch the app between English and Arabic.':
        'Switch the app between English and Arabic.',
    'TABLE': 'TABLE',
    'Table': 'Table',
    'Table is Prepared Ready Notice': 'Table is Prepared Ready Notice',
    'Table V5 · Window': 'Table V5 · Window',
    'Tandoor Spiced Lamb': 'Tandoor Spiced Lamb',
    'TAVOLA': 'TAVOLA',
    'Tavola AI': 'Tavola AI',
    'Tavola AI guides you to the perfect table for any occasion.':
        'Tavola AI guides you to the perfect table for any occasion.',
    'TAVOLA Concierge': 'TAVOLA Concierge',
    'TAVOLA REWARDS': 'TAVOLA REWARDS',
    'Thai': 'Thai',
    'This restaurant is not accepting new reservations right now.':
        'This restaurant is not accepting new reservations right now.',
    'THU': 'THU',
    'Thursday': 'Thursday',
    'Time': 'Time',
    'TODAY': 'TODAY',
    'TOMORROW': 'TOMORROW',
    'Torched Wagyu Nigiri': 'Torched Wagyu Nigiri',
    'Truffle Fries': 'Truffle Fries',
    'Tuesday': 'Tuesday',
    'Tuesday–Thursday': 'Tuesday–Thursday',
    'Curated kitchens, seasonal menus, and dining rooms chosen for craft, atmosphere, and lasting quality.':
        'Curated kitchens, seasonal menus, and dining rooms chosen for craft, atmosphere, and lasting quality.',
    'Unlocked': 'Unlocked',
    'Use at least 12 characters with upper and lower case letters, a number, and a symbol.':
        'Use at least 12 characters with upper and lower case letters, a number, and a symbol.',
    'Password must be at least @count characters.':
        'Password must be at least @count characters.',
    'Valet parking available': 'Valet parking available',
    'Vanilla Bean Panna Cotta': 'Vanilla Bean Panna Cotta',
    'VERIFY': 'VERIFY',
    'View all': 'View all',
    'View Details': 'View Details',
    'Warm brioche, sea urchin, and bright yuzu foam.':
        'Warm brioche, sea urchin, and bright yuzu foam.',
    'Warm soufflé with salted caramel cream.':
        'Warm soufflé with salted caramel cream.',
    'We sent a code to': 'We sent a code to',
    'WED': 'WED',
    'Wednesday': 'Wednesday',
    'WELCOME TO': 'WELCOME TO',
    'Wheelchair accessible': 'Wheelchair accessible',
    'Whole roasted fish with olive oil and garden herbs.':
        'Whole roasted fish with olive oil and garden herbs.',
    'WINDOW': 'WINDOW',
    'Window seat': 'Window seat',
    'Wood-Fired Mezze': 'Wood-Fired Mezze',
    'Would you like to review availability for "The Gilded Olive" tonight, or shall I recommend some curated Japanese plates at "Oma Sushi"?':
        'Would you like to review availability for "The Gilded Olive" tonight, or shall I recommend some curated Japanese plates at "Oma Sushi"?',
    'Your preferences have been saved. Table selection is next.':
        'Your preferences have been saved. Table selection is next.',
    'Your table has been reserved successfully.':
        'Your table has been reserved successfully.',
    'Your table is reserved at Otako Sushi. Share the code with your guests and arrive ready to unwind.':
        'Your table is reserved at Otako Sushi. Share the code with your guests and arrive ready to unwind.',
    'Yuzu Uni Toast': 'Yuzu Uni Toast',
  };

  static const Map<String, String> _ar = {
    'Business Lunch': 'غداء عمل',
    'Casual': 'عادي',
    'Cancelled': 'ملغى',
    'Celebration': 'احتفال',
    'Changing language': 'جاري تغيير اللغة',
    'Corporate': 'شركات',
    'Could not load map restaurants. Showing available pins.':
        'تعذر تحميل مطاعم الخريطة. يتم عرض المواقع المتاحة.',
    'Could not get your location. Please try again.':
        'تعذر الحصول على موقعك. حاول مرة أخرى.',
    'Date Night': 'سهرة رومانسية',
    'European': 'أوروبي',
    'Family': 'عائلة',
    'Fine Dining': 'طعام فاخر',
    'Friends': 'أصدقاء',
    'Fusion': 'فيوجن',
    'Gathering': 'تجمّع',
    'Group Gathering': 'تجمّع جماعي',
    'Korean': 'كوري',
    'Launch Business': 'إطلاق أعمال',
    'Lunch Business': 'غداء عمل',
    'Moroccan': 'مغربي',
    'Persian': 'فارسي',
    'Romantic': 'رومانسي',
    'Steak': 'ستيك',
    'Turkish': 'تركي',
    'Updating your dining experience': 'نحدّث تجربتك في التطبيق',
    ' SEATS': ' مقاعد',
    '07:30 PM': '07:30 م',
    '08:00 PM': '08:00 م',
    '08:30 PM': '08:30 م',
    '09:15 PM': '09:15 م',
    '1.5 H': '1.5 س',
    '11:00 AM – 12:00 AM': '11:00 ص – 12:00 ص',
    '12 Jul': '12 يوليو',
    '120 pts': '120 نقطة',
    '12:00 PM – 11:00 PM': '12:00 م – 11:00 م',
    '2 Guests': 'ضيفان',
    '2 H': '2 س',
    '2.5 H': '2.5 س',
    '380 points remaining': 'يتبقى 380 نقطة',
    '5:00 PM – 1:00 AM': '5:00 م – 1:00 ص',
    'ABOUT': 'نبذة',
    'Active always': 'نشط دائمًا',
    'Active dining placements': 'حجوزات الطعام النشطة',
    'All Restaurants': 'جميع المطاعم',
    'Always ready': 'جاهز دائمًا',
    'AM': 'ص',
    'Amber Ribeye': 'ريب آي أمبر',
    'Amber Terrace is an elevated steakhouse experience with candlelit tables, cellar pours, and panoramic evening views.':
        'Amber Terrace تجربة ستيك هاوس راقية بطاولات على ضوء الشموع ومشروبات من القبو وإطلالات مسائية بانورامية.',
    'Amber Terrace · Hillview': 'Amber Terrace · Hillview',
    'AMENITIES': 'المرافق',
    'American': 'أمريكي',
    'Anniversary': 'ذكرى سنوية',
    'April': 'أبريل',
    'Approved': 'مقبول',
    'Arabic': 'العربية',
    'Asian': 'آسيوي',
    'Ask Tavola AI for a recommendation...': 'اطلب توصية من Tavola AI...',
    'AUG': 'أغس',
    'August': 'أغسطس',
    'AVAILABLE': 'متاحة',
    'AVAILABLE TIME SLOTS': 'الأوقات المتاحة',
    'BBQ': 'مشاوي',
    'Being refreshed for the next service. This table will be ready shortly.':
        'تُجهَّز للخدمة التالية. ستكون هذه الطاولة جاهزة قريبًا.',
    'Birthday': 'عيد ميلاد',
    'Birthday tasting gift': 'هدية تذوق في عيد الميلاد',
    'Black Sesame Mousse': 'موس السمسم الأسود',
    'BOOK IN A FEW TAPS': 'احجز ببضع نقرات',
    'Book a table': 'احجز طاولة',
    'Book now': 'احجز الآن',
    'Booked': 'محجوز',
    'Booking': 'الحجز',
    'Browse by Occasion': 'تصفح حسب المناسبة',
    'Brunch': 'برانش',
    'Business': 'عمل',
    'Butter-Poached Lobster': 'لوبستر مسلوق بالزبدة',
    'Cafe': 'مقهى',
    'Call': 'اتصال',
    'Cancel': 'إلغاء',
    'Caramelized figs, almond cream, and wild honey.':
        'تين مكرمل، كريمة لوز، وعسل بري.',
    'Cardamom Rice Pudding': 'مهلبية أرز بالهيل',
    'Cedar Table offers modern comfort dining — polished cuts, hearth-kissed vegetables, and a room designed for lingering conversations.':
        'يقدّم Cedar Table طعامًا عصريًا مريحًا — قطعًا مصقولة وخضروات مشوية، وقاعة مصممة للمحادثات الطويلة.',
    'Cedar Table · Mayfair': 'Cedar Table · Mayfair',
    'Cedar-Smoked Steak': 'ستيك مدخن بالسيدار',
    'Ceremonial matcha with black sesame crumble.':
        'ماتشا احتفالي مع فتات السمسم الأسود.',
    'Change date': 'تغيير التاريخ',
    'Charcoal Aubergine': 'باذنجان على الفحم',
    'Charred greens with citrus vinaigrette.': 'خضروات مشوية مع تتبيلة حمضيات.',
    'Chat': 'المحادثة',
    'Sign in to message your dining host.':
        'سجّل الدخول لمراسلة مضيف الطعام.',
    'No conversations yet. Start one with a restaurant.':
        'لا توجد محادثات بعد. ابدأ محادثة مع مطعم.',
    'Could not load conversations. Please try again.':
        'تعذر تحميل المحادثات. يرجى المحاولة مرة أخرى.',
    'Could not load messages. Please try again.':
        'تعذر تحميل الرسائل. يرجى المحاولة مرة أخرى.',
    'Could not send your message. Please try again.':
        'تعذر إرسال الرسالة. يرجى المحاولة مرة أخرى.',
    'Could not start the conversation. Please try again.':
        'تعذر بدء المحادثة. يرجى المحاولة مرة أخرى.',
    'Could not close the conversation. Please try again.':
        'تعذر إغلاق المحادثة. يرجى المحاولة مرة أخرى.',
    'Start conversation': 'بدء محادثة',
    'Choose a restaurant': 'اختر مطعماً',
    'Close chat': 'إغلاق المحادثة',
    'All chats': 'كل المحادثات',
    'This conversation is closed.': 'هذه المحادثة مغلقة.',
    'You can start a new chat with another restaurant anytime.':
        'يمكنك بدء محادثة جديدة مع مطعم آخر في أي وقت.',
    'Chat with another restaurant': 'تحدث مع مطعم آخر',
    'Invalid conversation payload.': 'بيانات المحادثة غير صالحة.',
    'Invalid message payload.': 'بيانات الرسالة غير صالحة.',
    'CHECK YOUR WHATSAPP': 'تحقق من واتساب',
    'Chef’s table experiences': 'تجارب طاولة الشيف',
    'Chef’s tasting selection of seasonal spice plates.':
        'اختيار تذوق الشيف من أطباق التوابل الموسمية.',
    'Chilled dessert with pistachio brittle and gold leaf.':
        'حلوى باردة مع كسرات الفستق وورق الذهب.',
    'Chinese': 'صيني',
    'Choose your dining destination to begin crafting a refined reservation experience.':
        'اختر وجهتك لتناول الطعام لبدء تجربة حجز راقية.',
    'Choose your table and preferred seating to craft a refined dining experience.':
        'اختر طاولتك ومقعدك المفضل لصياغة تجربة طعام راقية.',
    'CLEANING': 'قيد التنظيف',
    'Closed': 'مغلق',
    'Vietnamese': 'فيتنامي',
    'Wedding': 'زفاف',
    '—': '—',
    'Restaurant details unavailable.': 'تفاصيل المطعم غير متوفرة.',
    'Could not load restaurant details.': 'تعذر تحميل تفاصيل المطعم.',
    'Coastal Salad': 'سلطة ساحلية',
    'Comfort-forward plates and perfect steak .': 'أطباق مريحة وستيك مثالي.',
    'Compact table being reset after lunch service — available again shortly.':
        'طاولة صغيرة تُعاد تجهيزها بعد الغداء — ستتوفر قريبًا.',
    'Completed': 'مكتمل',
    'Complimentary amuse-bouche': 'مقبّلات ترحيبية مجانية',
    'Concierge': 'المضيف',
    'Concierge Screen': 'شاشة المضيف',
    'Confirm': 'تأكيد',
    'CONFIRM RESERVATION': 'تأكيد الحجز',
    'Confirm your password': 'أكّد كلمة المرور',
    'Confirmation Code': 'رمز التأكيد',
    'Confirmed': 'مؤكد',
    'CONTACT': 'التواصل',
    'Contemporary': 'معاصر',
    'CONTINUE AS GUEST': 'المتابعة كزائر',
    'Corner booth reserved for a birthday celebration — unavailable for new bookings.':
        'مقصورة ركنية محجوزة لاحتفال عيد ميلاد — غير متاحة للحجوزات الجديدة.',
    'Cozy corner table with soft ambient lighting — ideal for relaxed conversations.':
        'طاولة ركنية مريحة بإضاءة هادئة — مثالية للمحادثات الهادئة.',
    'Create password': 'إنشاء كلمة المرور',
    'Choose a password for your account.': 'اختر كلمة مرور لحسابك.',
    'Enter your username and phone number to start reserving tables.':
        'أدخل اسم المستخدم ورقم هاتفك لبدء حجز الطاولات.',
    'Crisp duck with five-spice glaze and pickled plum.':
        'بط مقرمش بصلصة البهارات الخمس وبرقوق مخلل.',
    'Crisp fries finished with aged parmesan.':
        'بطاطس مقرمشة مع جبن بارميزان معتّق.',
    'Cuisines': 'المأكولات',
    'Curated wine cellar': 'قبو نبيذ مختار',
    'Currently held for an arriving party. Please choose another available table.':
        'محجوزة حاليًا لضيوف قادمين. يُرجى اختيار طاولة أخرى متاحة.',
    'Daily chef selection of nigiri and seasonal garnish.':
        'اختيار الشيف اليومي من النيجيري والزينة الموسمية.',
    'Dark Chocolate Soufflé': 'سوفليه شوكولاتة داكنة',
    'DATE': 'التاريخ',
    'Date': 'التاريخ',
    'December': 'ديسمبر',
    'Details': 'التفاصيل',
    'Details Screen': 'شاشة التفاصيل',
    'DINE AND EARN': 'تناول الطعام واكسب',
    'DINING': 'طعام',
    'Dinner': 'عشاء',
    'Directions': 'الاتجاهات',
    'DISMISS': 'إغلاق',
    'Drag and pinch to explore the dining room':
        'اسحب وقرّب لاستكشاف قاعة الطعام',
    'Dry-aged cut finished over cedar smoke.':
        'قطعة معتّقة جافًا تُنهى على دخان خشب السيدار.',
    'Early access to peak tables': 'وصول مبكر للطاولات في أوقات الذروة',
    'Earn points with every reservation and unlock refined dining privileges.':
        'اكسب نقاطًا مع كل حجز وافتح امتيازات طعام راقية.',
    'Elegant dining experience with refined spice blends.':
        'تجربة طعام أنيقة بمزيج من التوابل الراقية.',
    'Elm Avenue': 'شارع إلم',
    'Elm Avenue corner': 'زاوية شارع إلم',
    'Ember Salad': 'سلطة الجمر',
    'Emirati': 'إماراتي',
    'English': 'الإنجليزية',
    'Enjoy a premium dinner experience with chef-selected flavors and a warm atmosphere.':
        'استمتع بعشاء فاخر بنكهات يختارها الشيف وأجواء دافئة.',
    'Could not load offers. Please try again.':
        'تعذر تحميل العروض. يرجى المحاولة مرة أخرى.',
    'No special offers available right now.':
        'لا تتوفر عروض خاصة حالياً.',
    'Invalid offer payload.': 'بيانات العرض غير صالحة.',
    'Account created. Please log in.': 'تم إنشاء الحساب. يرجى تسجيل الدخول.',
    'Password updated. Please log in.':
        'تم تحديث كلمة المرور. يرجى تسجيل الدخول.',
    'This username is already taken. Please choose a different username.':
        'اسم المستخدم هذا مستخدم بالفعل. يرجى اختيار اسم مستخدم آخر.',
    'This phone number already has an account. Log in or use another number.':
        'رقم الهاتف هذا مرتبط بحساب بالفعل. سجّل الدخول أو استخدم رقمًا آخر.',
    'This username is taken, and this phone number already has an account. Please change them or log in.':
        'اسم المستخدم هذا مستخدم، ورقم الهاتف هذا مرتبط بحساب بالفعل. يرجى تغييرهما أو تسجيل الدخول.',
    'Choose a new password for your account.': 'اختر كلمة مرور جديدة لحسابك.',
    'Enter new password': 'أدخل كلمة المرور الجديدة',
    'Reset password': 'إعادة تعيين كلمة المرور',
    'Enter at least @count digits.': 'أدخل @count أرقام على الأقل.',
    'Enter a valid phone number for the selected country.':
        'أدخل رقم هاتف صالحاً للدولة المحددة.',
    'Enter the verification code we sent you.':
        'أدخل رمز التحقق الذي أرسلناه إليك.',
    'Enter your name': 'أدخل اسمك',
    'Enter your name.': 'أدخل اسمك.',
    'Enter your number': 'أدخل رقمك',
    'Enter your password': 'أدخل كلمة المرور',
    'Enter your username': 'أدخل اسم المستخدم',
    'Enter your username.': 'أدخل اسم المستخدم.',
    'ENTRANCE': 'المدخل',
    'EXAMPLE': 'مثال',
    'Exclusive Offers': 'عروض حصرية',
    'EXPERIENCE DURATION': 'مدة التجربة',
    'Explore': 'استكشف',
    'Explore more restaurants': 'استكشف المزيد من المطاعم',
    'Explore the dining room, choose an available table, and confirm your placement.':
        'استكشف قاعة الطعام، اختر طاولة متاحة، وأكّد مقعدك.',
    'EXPLORE THE GILDED OLIVE': 'استكشف The Gilded Olive',
    'Family-friendly seating': 'مقاعد مناسبة للعائلات',
    'Favorite': 'المفضلة',
    'Favorite Cuisines': 'المأكولات المفضلة',
    'Favorite dining selections': 'اختيارات الطعام المفضلة',
    'Favorites': 'المفضلة',
    'Favorites Screen': 'شاشة المفضلة',
    'February': 'فبراير',
    'Fennel, citrus, and toasted pine nuts.': 'شمر، حمضيات، وصنوبر محمص.',
    'Fig & Honey Tart': 'تارت التين والعسل',
    'Find me an intimate table for two tonight.':
        'ابحث لي عن طاولة حميمة لشخصين الليلة.',
    'Fine System Configurations': 'إعدادات النظام الدقيقة',
    'FLOOR PLAN': 'مخطط القاعة',
    'Forgot password?': 'هل نسيت كلمة المرور؟',
    'French': 'فرنسي',
    'FRI': 'جم',
    'Fri, 19 Aug': 'الجمعة، 19 أغسطس',
    'Fri, 19 Aug · 8:00 PM': 'الجمعة، 19 أغسطس · 8:00 م',
    'Friday': 'الجمعة',
    'Friday–Saturday': 'الجمعة–السبت',
    'Garden Street': 'شارع الحديقة',
    'Garden Street terrace': 'تراس شارع الحديقة',
    'Gentle lobster with herb beurre blanc.':
        'لوبستر لطيف مع صلصة الزبدة البيضاء بالأعشاب.',
    'GET STARTED': 'ابدأ الآن',
    'Golden Lantern is a contemporary Asian house known for bold textures, lacquered finishes, and tasting menus that feel cinematic.':
        'Golden Lantern منزل آسيوي معاصر يُعرف بقوامه الجريء ولمساته اللامعة وقوائم تذوق ذات طابع سينمائي.',
    'Good afternoon. I am your TAVOLA Concierge. I can guide you through premium seating, suggest perfect wine pairings, or coordinate an exquisite table reservation at any of our Mayfair partners.':
        'مساء الخير. أنا مضيف TAVOLA. يمكنني إرشادك إلى المقاعد الفاخرة، واقتراح أفضل تذوق للنبيذ، أو تنسيق حجز طاولة راقية لدى أي من شركائنا في Mayfair.',
    'Greek': 'يوناني',
    'Guest': 'ضيف',
    'GUESTS': 'الضيوف',
    'Guests': 'الضيوف',
    'guest_plural': 'ضيوف',
    'Gulf prawns finished with saffron butter and citrus leaf.':
        'روبيان الخليج بزبدة الزعفران وورق الحمضيات.',
    'Hand-folded dumplings in aromatic consommé.':
        'زلابية مطوية يدويًا في مرق عطري صافٍ.',
    'Heart of Old Town': 'قلب البلدة القديمة',
    'Hillview': 'هيلفيو',
    'Hillview rooftop': 'سطح هيلفيو',
    'Home': 'الرئيسية',
    'Host Member': 'عضو مضيف',
    'HOURS': 'الساعات',
    'Hours unavailable.': 'ساعات العمل غير متاحة.',
    'Hummus, grilled halloumi, and charcoal flatbread.':
        'حمص، حلوم مشوي، وخبز مسطح على الفحم.',
    'Indian': 'هندي',
    'Intimate two-seat table near the host stand, perfect for a quiet dinner.':
        'طاولة حميمة لمقعدين قرب منصة المضيف، مثالية لعشاء هادئ.',
    'Invitations for special Mayfair cellar wine pairings':
        'دعوات لتذوق نبيذ خاص من قبو Mayfair',
    'Invite friends': 'ادعُ أصدقاءك',
    'Italian': 'إيطالي',
    'January': 'يناير',
    'Japanese': 'ياباني',
    'Japanese · Sushi': 'ياباني · سوشي',
    'July': 'يوليو',
    'June': 'يونيو',
    'Lacquered Duck': 'بط مطلي',
    'Language': 'اللغة',
    'Large party table reserved for a corporate dinner event this evening.':
        'طاولة كبيرة محجوزة لعشاء شركات هذا المساء.',
    'Late Arrival Automatically Inform': 'إبلاغ تلقائي بالتأخر',
    'Late seating priority': 'أولوية في الجلوس المتأخر',
    'Le Menu': 'القائمة',
    'Lebanese': 'لبناني',
    'Lemon Herb Sea Bass': 'قاروص بالليمون والأعشاب',
    'Let hosts know you are delayed via dynamic chat dispatches':
        'أخبر المضيفين بتأخرك عبر رسائل المحادثة الفورية',
    'Limited': 'محدود',
    'Live alert when hostess prepares physical placement':
        'تنبيه فوري عند تجهيز المضيفة لمقعدك',
    'Live availability, instant booking, and smart reminders.':
        'توفر لحظي، حجز فوري، وتذكيرات ذكية.',
    'Live evening music': 'موسيقى حية مسائية',
    'Located in North District’s creative loft quarter, easy to reach by metro and rideshare.':
        'يقع في حي اللوفت الإبداعي بالحي الشمالي، ويسهل الوصول إليه بالمترو وتطبيقات التوصيل.',
    'LOGIN': 'تسجيل الدخول',
    'LOGIN / SIGN UP': 'تسجيل الدخول / إنشاء حساب',
    'Login with your phone number and password':
        'سجّل الدخول برقم هاتفك وكلمة المرور',
    'Enter your email': 'أدخل بريدك الإلكتروني',
    'Enter a valid email address.': 'أدخل بريداً إلكترونياً صالحاً.',
    'Log out': 'تسجيل الخروج',
    'Lunch': 'غداء',
    'Make it a group experience! (Optional)': 'اجعلها تجربة جماعية! (اختياري)',
    'Manage details, share your code, and reach your host in one place.':
        'أدِر التفاصيل، شارك رمزك، وتواصل مع مضيفك من مكان واحد.',
    'Map': 'الخريطة',
    'March': 'مارس',
    'Marina Bay': 'مارينا باي',
    'Marina waterfront': 'واجهة مارينا البحرية',
    'Matcha Soft Serve': 'آيس كريم ماتشا',
    'May': 'مايو',
    'Mayfair Thali': 'ثالي Mayfair',
    'Mediterranean': 'متوسطي',
    'Member Privileges': 'امتيازات العضوية',
    'Menu': 'القائمة',
    'Burrata Caprese': 'بوراتا كابريزي',
    'Creamy burrata with heirloom tomatoes and basil oil.':
        'بوراتا كريمية مع طماطم وطعم الريحان.',
    'Crispy Calamari': 'كاليماري مقرمش',
    'Lightly fried squid with lemon aioli and chili salt.':
        'حبار مقلي خفيف مع أيولي الليمون وملح الفلفل.',
    'Mushroom Risotto': 'ريزوتو الفطر',
    'Arborio rice with wild mushrooms and aged parmesan.':
        'أرز أربوريو مع فطر بري وجبن بارميزان معتق.',
    'Grilled Octopus': 'أخطبوط مشوي',
    'Charred octopus with smoked paprika and olive salsa.':
        'أخطبوط مشوي مع بابريكا مدخنة وصلصة الزيتون.',
    'Beef Tartare': 'تارتار لحم',
    'Hand-cut beef with quail egg, capers, and toasted brioche.':
        'لحم مقطّع يدوياً مع بيض سمان وكبر وبريوش محمص.',
    'Lobster Mac': 'ماكاروني اللوبستر',
    'Baked macaroni with lobster, gruyère, and herb crumb.':
        'ماكاروني مخبوز مع لوبستر وجرويير وفتات الأعشاب.',
    'Seared Scallops': 'سكالوب محمر',
    'Caramelized scallops with cauliflower purée and brown butter.':
        'سكالوب مكرمل مع مهروس قرنبيط وزبدة بنية.',
    'Lamb Kofta': 'كفتة لحم',
    'Spiced lamb skewers with mint yogurt and flatbread.':
        'أسياخ لحم متبّل مع لبن النعناع وخبز مسطح.',
    'Prawn Linguine': 'لينغويني الروبيان',
    'Fresh linguine with garlic prawns and chili oil.':
        'لينغويني طازج مع روبيان وثوم وزيت الفلفل.',
    'Duck Confit': 'بط كونفي',
    'Slow-cooked duck leg with orange glaze and greens.':
        'فخذ بط مطهو ببطء مع صوص البرتقال والخضار.',
    'Tiramisu': 'تيراميسو',
    'Classic espresso tiramisu with mascarpone cream.':
        'تيراميسو كلاسيكي مع كريمة الماسكاربوني.',
    'Citrus Panna Cotta': 'بانا كوتا حمضية',
    'Vanilla panna cotta with blood-orange syrup.':
        'بانا كوتا فانيلا مع شراب البرتقال الدموي.',
    'Message your dining host...': 'راسل مضيف الطعام...',
    'Mexican': 'مكسيكي',
    'Modern tasting menu with signature pours.':
        'قائمة تذوق عصرية مع مشروبات مميزة.',
    'Monday': 'الاثنين',
    'Monday–Saturday': 'الاثنين–السبت',
    'Enable location for nearby restaurants':
        'فعّل الموقع لعرض المطاعم القريبة',
    'Enable': 'تفعيل',
    'Finding your location…': 'جاري تحديد موقعك…',
    'Location permission is required for nearby recommendations.':
        'إذن الموقع مطلوب لتوصيات المطاعم القريبة.',
    'Location access is blocked. Open Settings to enable it.':
        'تم حظر الوصول إلى الموقع. افتح الإعدادات لتفعيله.',
    'Location access is restricted on this device.':
        'الوصول إلى الموقع مقيد على هذا الجهاز.',
    'Turn on Location Services to see nearby restaurants.':
        'شغّل خدمات الموقع لعرض المطاعم القريبة.',
    'Open Settings': 'فتح الإعدادات',
    'Open Location Settings': 'فتح إعدادات الموقع',
    'Your location is currently unavailable.': 'موقعك غير متاح حالياً.',
    'Near you': 'بالقرب منك',
    'NEAR DUBAI, JBR': 'بالقرب من دبي، جميرا بيتش ريزيدنس',
    'Need 60 more points': 'تحتاج إلى 60 نقطة إضافية',
    'Nestled along Old Town’s quiet lanes, a short stroll from the heritage square and evening markets.':
        'يقع بين أزقة البلدة القديمة الهادئة، على مسافة قصيرة سيرًا من الساحة التراثية وأسواق المساء.',
    'NEXT : SELECT TABLE': 'التالي: اختر الطاولة',
    'NEXT: SILVER HOST': 'التالي: مضيف فضي',
    'North District': 'الحي الشمالي',
    'North District loft': 'لوفت الحي الشمالي',
    'No cuisine categories available.': 'لا توجد فئات مطابخ متاحة.',
    'No occasion categories available.': 'لا توجد فئات مناسبات متاحة.',
    'No restaurants available.': 'لا توجد مطاعم متاحة.',
    'Restaurant catalog is not available for customer accounts on this API yet.':
        'كتالوج المطاعم غير متاح حالياً لحسابات العملاء على هذا الـ API.',
    'Restaurant API is not yet available.':
        'واجهة برمجة تطبيقات المطاعم غير متاحة بعد.',
    'No tables available.': 'لا توجد طاولات متاحة.',
    'No branch is available for this restaurant.':
        'لا يوجد فرع متاح لهذا المطعم.',
    'No floor plan is available for this restaurant.':
        'لا تتوفر خريطة طاولات لهذا المطعم.',
    'Notifications': 'الإشعارات',
    'No notifications yet.': 'لا توجد إشعارات بعد.',
    'Mark all read': 'تعليم الكل كمقروء',
    '99+': '٩٩+',
    'Sign in to view your notifications.': 'سجّل الدخول لعرض إشعاراتك.',
    'Invalid notification payload.': 'بيانات الإشعار غير صالحة.',
    'Join waitlist': 'الانضمام لقائمة الانتظار',
    'You are on the waitlist. We will notify you when a table opens.':
        'أنت على قائمة الانتظار. سنُعلمك عند توفر طاولة.',
    'Could not join the waitlist. Please try again.':
        'تعذر الانضمام لقائمة الانتظار. حاول مرة أخرى.',
    'Leave waitlist': 'مغادرة قائمة الانتظار',
    'You have left the waitlist.': 'لقد غادرت قائمة الانتظار.',
    'Could not leave the waitlist. Please try again.':
        'تعذر مغادرة قائمة الانتظار. حاول مرة أخرى.',
    'Invalid waitlist payload.': 'بيانات قائمة الانتظار غير صالحة.',
    'Invalid restaurant payload.': 'بيانات المطعم غير صالحة.',
    'Invalid branch payload.': 'بيانات الفرع غير صالحة.',
    'Invalid table payload.': 'بيانات الطاولة غير صالحة.',
    'Invalid reservation payload.': 'بيانات الحجز غير صالحة.',
    'Could not create reservation. Please try again.':
        'تعذر إنشاء الحجز. حاول مرة أخرى.',
    'Could not load reservations. Please try again.':
        'تعذر تحميل الحجوزات. حاول مرة أخرى.',
    'Could not load your reviews.': 'تعذر تحميل تقييماتك.',
    'Could not load the menu. Please try again.':
        'تعذر تحميل القائمة. حاول مرة أخرى.',
    'Could not submit your review.': 'تعذر إرسال تقييمك.',
    'Could not remove your review.': 'تعذر حذف تقييمك.',
    'Choose a rating from 1 to 5.': 'اختر تقييماً من 1 إلى 5.',
    'Invalid review payload.': 'بيانات التقييم غير صالحة.',
    'Invalid review rating.': 'تقييم غير صالح.',
    'No menu items available.': 'لا توجد أصناف في القائمة.',
    'Invalid menu payload.': 'بيانات القائمة غير صالحة.',
    'Could not load table availability. Please try again.':
        'تعذر تحميل توفر الطاولات. حاول مرة أخرى.',
    'Choose a date, time, and party size before selecting a table.':
        'اختر التاريخ والوقت وعدد الضيوف قبل اختيار الطاولة.',
    'Invalid user profile payload.': 'بيانات الملف الشخصي غير صالحة.',
    'Invalid user preferences payload.': 'بيانات التفضيلات غير صالحة.',
    'No profile available.': 'لا يوجد ملف شخصي متاح.',
    'No reservations yet': 'لا توجد حجوزات بعد',
    'Your upcoming tables will appear here — reserve a place and return for a refined overview of every seating.':
        'ستظهر طاولاتك القادمة هنا — احجز مقعدًا وعد لعرض أنيق لكل جلسة.',
    'Could not upload avatar. Please try again.':
        'تعذر رفع الصورة. حاول مرة أخرى.',
    'Could not update preferences. Please try again.':
        'تعذر تحديث التفضيلات. حاول مرة أخرى.',
    'Could not update profile. Please try again.':
        'تعذر تحديث الملف الشخصي. حاول مرة أخرى.',
    'Change photo': 'تغيير الصورة',
    'Account details': 'بيانات الحساب',
    'First name': 'الاسم الأول',
    'Last name': 'اسم العائلة',
    'Phone': 'الهاتف',
    'Preferred currency': 'العملة المفضلة',
    'Save changes': 'حفظ التغييرات',
    'Profile updated.': 'تم تحديث الملف الشخصي.',
    'Reservation notifications': 'إشعارات الحجوزات',
    'Receive reminders and updates about your reservations.':
        'استلم تذكيرات وتحديثات عن حجوزاتك.',
    'Marketing & promotions': 'العروض والتسويق',
    'Receive offers, events, and concierge invitations.':
        'استلم العروض والفعاليات ودعوات الكونسيرج.',
    'Cancel reservation': 'إلغاء الحجز',
    'Reschedule': 'إعادة الجدولة',
    'Are you sure?': 'هل أنت متأكد؟',
    'Yes': 'نعم',
    'No': 'لا',
    'Cancel this reservation?': 'إلغاء هذا الحجز؟',
    'Reschedule this reservation?': 'إعادة جدولة هذا الحجز؟',
    'Log out of your account?': 'تسجيل الخروج من حسابك؟',
    'Not finding a place to eat? Ask Tavola AI':
        'لم تجد مكانًا لتناول الطعام؟ اسأل Tavola AI',
    'November': 'نوفمبر',
    'NOWTIME': 'الوقت الآن',
    'NUMBER OF DINERS': 'عدد الضيوف',
    'Occasions': 'المناسبات',
    'October': 'أكتوبر',
    'Old Town': 'البلدة القديمة',
    'Olive & Oak blends Mediterranean ease with rustic elegance, serving sunlit plates that feel like a long afternoon by the coast.':
        'يمزج Olive & Oak سهولة المتوسط مع أناقة ريفية، ويقدّم أطباقًا مشمسة تشبه عصرًا طويلًا على الساحل.',
    'Olive & Oak has a quiet window table at 8:30 PM — soft lighting and garden views.':
        'يتوفر لدى Olive & Oak طاولة هادئة بجانب النافذة الساعة 8:30 م — إضاءة ناعمة وإطلالة على الحديقة.',
    'Omakase Duo': 'أوماكاسي ثنائي',
    'On Elm Avenue’s dining strip, with valet at the entrance and shaded sidewalk seating.':
        'على شريط المطاعم في شارع إلم، مع خدمة صف عند المدخل ومقاعد مظللة على الرصيف.',
    'Open': 'مفتوح',
    'Open now': 'مفتوح الآن',
    'OpenStreetMap contributors': 'مساهمو OpenStreetMap',
    'CARTO': 'CARTO',
    'OpenStreetMap · CARTO': 'OpenStreetMap · CARTO',
    'Otako Sushi celebrates precision and calm — each plate composed with seasonal fish, house-aged soy, and a quiet reverence for Japanese craft.':
        'يحتفي Otako Sushi بالدقة والهدوء — كل طبق يُركَّب بأسماك موسمية وصلصة صويا معتّقة وتقدير هادئ للحرفة اليابانية.',
    'Outdoor terrace seating': 'مقاعد تراس خارجي',
    'Overlooking Marina Bay, with waterfront access and a serene approach from the promenade.':
        'يطل على مارينا باي، مع وصول مباشر للواجهة البحرية وممر هادئ من الممشى.',
    'Passwords do not match.': 'كلمتا المرور غير متطابقتين.',
    'Last Reservations': 'آخر الحجوزات',
    'Payment history': 'سجل المدفوعات',
    'Payments': 'المدفوعات',
    'Pending': 'قيد الانتظار',
    'Rate your visit': 'قيّم زيارتك',
    'Your review': 'تقييمك',
    'Write a review': 'اكتب تقييماً',
    'Submit review': 'إرسال التقييم',
    'Share a few words about your evening.': 'شاركنا بضع كلمات عن أمسيتك.',
    'Review submitted successfully.': 'تم إرسال التقييم بنجاح.',
    'Review removed.': 'تم حذف التقييم.',
    'Remove this review? This cannot be undone.':
        'حذف هذا التقييم؟ لا يمكن التراجع عن ذلك.',
    'Remove review': 'حذف التقييم',
    'Add photo': 'إضافة صورة',
    'Optional photo': 'صورة اختيارية',
    'Tap a star to rate': 'اضغط على نجمة للتقييم',
    'Reservation history': 'سجل الحجوزات',
    'Perched above Hillview, offering elevated city views and a discreet rooftop entrance.':
        'يعلو هيلفيو، ويوفّر إطلالات مرتفعة على المدينة ومدخلًا سريًا إلى السطح.',
    'Pet-friendly patio': 'فناء مناسب للحيوانات الأليفة',
    'Please select an available table to continue.':
        'يُرجى اختيار طاولة متاحة للمتابعة.',
    'PM': 'م',
    'Points': 'النقاط',
    'Preferred time': 'الوقت المفضل',
    'Premium cuts and candlelit evenings.': 'قطع فاخرة وأمسيات على ضوء الشموع.',
    'Premium window seating with panoramic city views, natural daylight, and a quiet atmosphere — ideal for intimate dining and special occasions.':
        'مقاعد نافذة فاخرة بإطلالة بانورامية على المدينة وضوء طبيعي وأجواء هادئة — مثالية للعشاء الحميمي والمناسبات الخاصة.',
    'Preview the floor plan and pick your favorite seat.':
        'اطّلع على مخطط القاعة واختر مقعدك المفضل.',
    'Prime ribeye with bone marrow butter.': 'ريب آي ممتاز بزبدة نخاع العظم.',
    'Private dining rooms': 'غرف طعام خاصة',
    'Private parking on-site': 'موقف سيارات خاص في الموقع',
    'Profile': 'الملف الشخصي',
    'Promotions & Concierge Events': 'العروض وفعاليات المضيف',
    'QR CODE': 'رمز QR',
    'Quick actions': 'إجراءات سريعة',
    'Ready': 'جاهز',
    'Receive 2-hour arrival warnings and hosts updates':
        'تلقَّ تنبيهات قبل ساعتين من الوصول وتحديثات المضيفين',
    'Redeemed': 'تم الاستبدال',
    'REFERENCE : ': 'المرجع : ',
    'RESEND IT': 'إعادة الإرسال',
    'Reservation': 'الحجز',
    'Reservation Preferences': 'تفضيلات الحجز',
    'Reservation Reminder Notifications': 'إشعارات تذكير الحجز',
    'Reservation request selected.': 'تم اختيار طلب الحجز.',
    'Reservation Screen': 'شاشة الحجز',
    'Reservation summary': 'ملخص الحجز',
    'Reservations': 'الحجوزات',
    'Reserve Table': 'احجز طاولة',
    'RESERVED': 'محجوزة',
    'Retry': 'إعادة المحاولة',
    'RESTAURANT': 'المطعم',
    'Restaurant details selected.': 'تم اختيار تفاصيل المطعم.',
    'Restaurants near you': 'مطاعم بالقرب منك',
    'Roasted Root Bowl': 'وعاء الجذور المشوية',
    'Rooftop lounge access': 'دخول إلى صالة السطح',
    'Saffron Butter Prawns': 'روبيان بزبدة الزعفران',
    'Saffron House is a refined sanctuary of spice and warmth, where chef-led tasting journeys unfold beneath soft amber lighting and hand-carved teak panels.':
        'Saffron House ملاذ راقٍ من التوابل والدفء، حيث تنكشف رحلات التذوق بإشراف الشيف تحت إضاءة كهرمانية ناعمة وألواح خشب الساج المنحوتة يدويًا.',
    'SAT': 'سب',
    'Saturday': 'السبت',
    'Save': 'حفظ',
    'Saved': 'محفوظ',
    'Something went wrong. Please try again.': 'حدث خطأ ما. حاول مرة أخرى.',
    'Unable to connect. Check your internet connection.':
        'تعذر الاتصال. تحقق من اتصال الإنترنت.',
    'The request timed out. Please try again.':
        'انتهت مهلة الطلب. حاول مرة أخرى.',
    'Your session has expired. Please sign in again.':
        'انتهت جلستك. يرجى تسجيل الدخول مرة أخرى.',
    'Please sign in to continue.': 'يرجى تسجيل الدخول للمتابعة.',
    'Invalid phone or password. Please try again.':
        'رقم الهاتف أو كلمة المرور غير صحيحة. حاول مرة أخرى.',
    'You do not have permission to perform this action.':
        'ليس لديك صلاحية لتنفيذ هذا الإجراء.',
    'The requested resource was not found.': 'المورد المطلوب غير موجود.',
    'Too many attempts. Please wait and try again.':
        'محاولات كثيرة جداً. انتظر ثم حاول مرة أخرى.',
    'Invalid authentication session payload.':
        'بيانات جلسة المصادقة غير صالحة.',
    'Invalid registration response.': 'استجابة التسجيل غير صالحة.',
    'Your session could not be refreshed. Please sign in again.':
        'تعذر تحديث جلستك. يرجى تسجيل الدخول مرة أخرى.',
    'The server is unavailable right now.': 'الخادم غير متاح حالياً.',
    'Seafood': 'مأكولات بحرية',
    'Search country': 'ابحث عن دولة',
    'Search restaurants': 'ابحث عن مطاعم',
    'Search Resturant': 'ابحث عن مطعم',
    'Seared wagyu with truffle soy and crisp shallot.':
        'واغيو محمر مع صويا الكمأة وبصل مقرمش.',
    'Seasonal plates with warm, rustic charm.': 'أطباق موسمية بسحر ريفي دافئ.',
    'Seasonal roots, hazelnut butter, and thyme.':
        'جذور موسمية، زبدة بندق، وزعتر.',
    'SELECT DATE': 'اختر التاريخ',
    'Select the cuisines you enjoy the most to get personalized recommendations.':
        'اختر المأكولات التي تفضلها أكثر للحصول على توصيات مخصصة.',
    'Select your restaurant': 'اختر مطعمك',
    'Select your table': 'اختر طاولتك',
    'SELECTED': 'محدد',
    'SELECTED TABLE': 'الطاولة المحددة',
    'September': 'سبتمبر',
    'SERVICE': 'خدمة',
    'Set on Garden Street beside olive trees and soft courtyard lighting for warm arrivals.':
        'يقع في شارع الحديقة بجانب أشجار الزيتون وإضاءة فناء ناعمة لاستقبال دافئ.',
    'Settings': 'الإعدادات',
    'Settings Screen': 'شاشة الإعدادات',
    'SIGN IN': 'تسجيل الدخول',
    'SIGN UP': 'إنشاء حساب',
    'Silk Broth Dumplings': 'زلابية في مرق حريري',
    'Silky mousse with cherry gel and crisp tuile.':
        'موس حريري مع هلام الكرز ورقاقة مقرمشة.',
    'Skip for Now': 'تخطَّ الآن',
    'Slow-roasted rack with rose petal glaze and mint oil.':
        'ضلع مشوي ببطء مع صلصة بتلات الورد وزيت النعناع.',
    'Smoked aubergine with miso butter and sesame.':
        'باذنجان مدخن بزبدة الميسو والسمسم.',
    'Social': 'اجتماعي',
    'Soft set cream with berry reduction.': 'كريمة طرية مع اختزال التوت.',
    'Spacious booth with lounge seating and generous space for larger gatherings.':
        'مقصورة واسعة بمقاعد مريحة ومساحة كافية للتجمعات الكبيرة.',
    'Spanish': 'إسباني',
    'Special Offer': 'عرض خاص',
    'STATUS': 'الحالة',
    'STAY IN CONTROL': 'ابقَ متحكمًا',
    'Steakhouse': 'ستيك هاوس',
    'Vegetarian': 'نباتي',
    'Street parking nearby': 'موقف في الشارع قريب',
    'Sunday': 'الأحد',
    'Sushi': 'سوشي',
    'Sushi by a special chief.': 'سوشي من إعداد شيف مميز.',
    'SWIPE TO EXPLORE': 'اسحب لاستكشاف المزيد',
    'Switch the app between English and Arabic.':
        'بدّل التطبيق بين الإنجليزية والعربية.',
    'TABLE': 'الطاولة',
    'Table': 'طاولة',
    'Table is Prepared Ready Notice': 'إشعار جاهزية الطاولة',
    'Table V5 · Window': 'طاولة V5 · نافذة',
    'Tandoor Spiced Lamb': 'لحم ضأن متبل بالتندور',
    'TAVOLA': 'TAVOLA',
    'Tavola AI': 'Tavola AI',
    'Tavola AI guides you to the perfect table for any occasion.':
        'يرشدك Tavola AI إلى الطاولة المثالية لأي مناسبة.',
    'TAVOLA Concierge': 'TAVOLA Concierge',
    'TAVOLA REWARDS': 'مكافآت TAVOLA',
    'Thai': 'تايلندي',
    'This restaurant is not accepting new reservations right now.':
        'هذا المطعم لا يقبل حجوزات جديدة في الوقت الحالي.',
    'THU': 'خم',
    'Thursday': 'الخميس',
    'Time': 'الوقت',
    'TODAY': 'اليوم',
    'TOMORROW': 'غدًا',
    'Torched Wagyu Nigiri': 'نيجيري واغيو مشوي',
    'Truffle Fries': 'بطاطس مقلية بالكمأة',
    'Tuesday': 'الثلاثاء',
    'Tuesday–Thursday': 'الثلاثاء–الخميس',
    'Curated kitchens, seasonal menus, and dining rooms chosen for craft, atmosphere, and lasting quality.':
        'مطابخ منتقاة وقوائم موسمية وقاعات طعام مختارة للحِرفة والأجواء والجودة التي تدوم.',
    'Unlocked': 'تم الفتح',
    'Use at least 12 characters with upper and lower case letters, a number, and a symbol.':
        'استخدم 12 حرفًا على الأقل مع أحرف كبيرة وصغيرة ورقم ورمز.',
    'Password must be at least @count characters.':
        'يجب أن تتكون كلمة المرور من @count حرفًا على الأقل.',
    'Valet parking available': 'خدمة صف السيارات متاحة',
    'Vanilla Bean Panna Cotta': 'بانا كوتا بفانيليا',
    'VERIFY': 'تحقق',
    'View all': 'عرض الكل',
    'View Details': 'عرض التفاصيل',
    'Warm brioche, sea urchin, and bright yuzu foam.':
        'بريوش دافئ، قنفذ بحر، ورغوة يوزو منعشة.',
    'Warm soufflé with salted caramel cream.':
        'سوفليه دافئ مع كريمة كراميل مملح.',
    'We sent a code to': 'أرسلنا رمزًا إلى',
    'WED': 'أرب',
    'Wednesday': 'الأربعاء',
    'WELCOME TO': 'مرحبًا بك في',
    'Wheelchair accessible': 'ملائم لذوي الإعاقة الحركية',
    'Whole roasted fish with olive oil and garden herbs.':
        'سمكة كاملة مشوية بزيت الزيتون وأعشاب الحديقة.',
    'WINDOW': 'نافذة',
    'Window seat': 'مقعد بجانب النافذة',
    'Wood-Fired Mezze': 'مزّة على الحطب',
    'Would you like to review availability for "The Gilded Olive" tonight, or shall I recommend some curated Japanese plates at "Oma Sushi"?':
        'هل تريد مراجعة التوفر في "The Gilded Olive" الليلة، أم أقترح عليك أطباقًا يابانية مختارة في "Oma Sushi"؟',
    'Your preferences have been saved. Table selection is next.':
        'تم حفظ تفضيلاتك. الخطوة التالية هي اختيار الطاولة.',
    'Your table has been reserved successfully.': 'تم حجز طاولتك بنجاح.',
    'Your table is reserved at Otako Sushi. Share the code with your guests and arrive ready to unwind.':
        'تم حجز طاولتك في Otako Sushi. شارك الرمز مع ضيوفك وصل مستعدًا للاسترخاء.',
    'Yuzu Uni Toast': 'توست يوزو وأوني',
  };
}
