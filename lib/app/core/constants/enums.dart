

enum LoadStatus { pickup, inTransit, delivered }

class SortProduct {
  static const newest = 'newest';
  static const priceLowToHigh = 'price_low_to_high';
  static const priceHighToLow = 'price_high_to_low';
  static const ratingHighToLow = 'rating_high_to_low';
  static const ratingLowToHigh = 'rating_low_to_high';
}

class OrderStatus {
  static const pending = 'pending';
  static const confirmed = 'confirmed';
  static const packaging = 'packaging';
  static const outOfDelivery = 'out_of_delivery';
  static const delivered = 'delivered';
  static const failedToDeliver = 'failed_to_deliver';
  static const cancelled = 'cancelled';
  static const returned = 'returned';
}

class SaveAddressAs {
  static const home = 'home';
  static const office = 'office';
  static const other = 'other';
}
