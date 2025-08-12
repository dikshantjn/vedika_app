import 'package:flutter/foundation.dart';

class ProductPartnerAnalysisData {
  final DemandSalesTrends demandSalesTrends;
  final InventoryInsights inventoryInsights;
  final OperationalEfficiency operationalEfficiency;
  final CustomerBehaviorGeography customerBehaviorGeography;
  final RevenueProfitability revenueProfitability;
  final PredictiveStrategicInsights predictiveStrategicInsights;

  ProductPartnerAnalysisData({
    required this.demandSalesTrends,
    required this.inventoryInsights,
    required this.operationalEfficiency,
    required this.customerBehaviorGeography,
    required this.revenueProfitability,
    required this.predictiveStrategicInsights,
  });
}

class DemandSalesTrends {
  final List<int> orderVolumeTrendWeekly;
  final Map<String, double> productCategoryPerformance;
  final List<String> fastMovingProducts;
  final List<String> slowMovingProducts;
  final double firstTimeToRepeatBuyerRatio;
  final double bulkToSingleOrderRatio;

  DemandSalesTrends({
    required this.orderVolumeTrendWeekly,
    required this.productCategoryPerformance,
    required this.fastMovingProducts,
    required this.slowMovingProducts,
    required this.firstTimeToRepeatBuyerRatio,
    required this.bulkToSingleOrderRatio,
  });
}

class InventoryInsights {
  final Map<String, int> stockOutFrequencyPerProduct;
  final double inventoryTurnoverRate;
  final Map<String, int> daysOfStockLeft;
  final List<String> overstockAlerts;

  InventoryInsights({
    required this.stockOutFrequencyPerProduct,
    required this.inventoryTurnoverRate,
    required this.daysOfStockLeft,
    required this.overstockAlerts,
  });
}

class OperationalEfficiency {
  final double averageTimeToConfirmHours;
  final double averageTimeOrderToDispatchHours;
  final Map<String, int> returnRefundReasons;
  final double deliverySuccessRateFirstAttempt;

  OperationalEfficiency({
    required this.averageTimeToConfirmHours,
    required this.averageTimeOrderToDispatchHours,
    required this.returnRefundReasons,
    required this.deliverySuccessRateFirstAttempt,
  });
}

class CustomerBehaviorGeography {
  final Map<String, List<String>> highDemandRegionsByProductType;
  final List<String> purchasePatterns;
  final List<Map<String, dynamic>> topCustomersByOrderValue;
  final Map<String, List<String>> geographicProductPreference;

  CustomerBehaviorGeography({
    required this.highDemandRegionsByProductType,
    required this.purchasePatterns,
    required this.topCustomersByOrderValue,
    required this.geographicProductPreference,
  });
}

class RevenueProfitability {
  final Map<String, double> revenueByProduct;
  final Map<String, double> revenueByCategory;
  final Map<String, double> revenueByRegion;
  final Map<String, double> profitMarginsByItem;
  final Map<String, double> seasonalRevenueShifts;

  RevenueProfitability({
    required this.revenueByProduct,
    required this.revenueByCategory,
    required this.revenueByRegion,
    required this.profitMarginsByItem,
    required this.seasonalRevenueShifts,
  });
}

class PredictiveStrategicInsights {
  final List<String> restockPredictionAlerts;
  final Map<String, List<String>> crossSellingRecommendations;
  final Map<String, double> promotionsImpactUpliftPercent;
  final List<String> emergingProductDemand;

  PredictiveStrategicInsights({
    required this.restockPredictionAlerts,
    required this.crossSellingRecommendations,
    required this.promotionsImpactUpliftPercent,
    required this.emergingProductDemand,
  });
}

class ProductPartnerAnalysisService {
  Future<ProductPartnerAnalysisData> getAnalysis(String vendorId) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));

    final demandSales = DemandSalesTrends(
      orderVolumeTrendWeekly: [32, 54, 48, 70, 65, 40, 52],
      productCategoryPerformance: {
        'Mobility Aids': 42000.0,
        'Diagnostic Devices': 36000.0,
        'Orthopedic': 18000.0,
      },
      fastMovingProducts: ['Wheelchair X2', 'BP Monitor A1', 'Pulse Oximeter Pro'],
      slowMovingProducts: ['Infrared Thermometer Basic', 'Nebulizer Mini'],
      firstTimeToRepeatBuyerRatio: 1.8,
      bulkToSingleOrderRatio: 0.35,
    );

    final inventory = InventoryInsights(
      stockOutFrequencyPerProduct: {
        'Wheelchair X2': 3,
        'BP Monitor A1': 2,
        'Crutches Lite': 1,
      },
      inventoryTurnoverRate: 6.4,
      daysOfStockLeft: {
        'Wheelchair X2': 14,
        'BP Monitor A1': 9,
        'Pulse Oximeter Pro': 21,
      },
      overstockAlerts: ['Infrared Thermometer Basic', 'Nebulizer Mini'],
    );

    final ops = OperationalEfficiency(
      averageTimeToConfirmHours: 1.3,
      averageTimeOrderToDispatchHours: 18.5,
      returnRefundReasons: {
        'Damaged on arrival': 5,
        'Wrong size/spec': 7,
        'Changed mind': 3,
      },
      deliverySuccessRateFirstAttempt: 0.92,
    );

    final customer = CustomerBehaviorGeography(
      highDemandRegionsByProductType: {
        'Mobility Aids': ['Delhi', 'Mumbai'],
        'Diagnostic Devices': ['Bengaluru', 'Hyderabad'],
      },
      purchasePatterns: [
        'Walker + Grip Gloves',
        'BP Monitor + Spare Cuff',
        'Wheelchair + Seat Cushion',
      ],
      topCustomersByOrderValue: [
        {'name': 'City Care Hospital', 'value': 155000.0},
        {'name': 'HealthPlus Clinic', 'value': 82000.0},
        {'name': 'Dr. Ananya Mehra', 'value': 46000.0},
      ],
      geographicProductPreference: {
        'North': ['Wheelchair X2', 'Crutches Lite'],
        'South': ['BP Monitor A1', 'Pulse Oximeter Pro'],
      },
    );

    final revenue = RevenueProfitability(
      revenueByProduct: {
        'Wheelchair X2': 24000.0,
        'BP Monitor A1': 18000.0,
        'Pulse Oximeter Pro': 12000.0,
      },
      revenueByCategory: {
        'Mobility Aids': 42000.0,
        'Diagnostic Devices': 36000.0,
      },
      revenueByRegion: {
        'North': 38000.0,
        'South': 26000.0,
        'West': 14000.0,
      },
      profitMarginsByItem: {
        'Wheelchair X2': 0.28,
        'BP Monitor A1': 0.35,
        'Pulse Oximeter Pro': 0.30,
      },
      seasonalRevenueShifts: {
        'Q1': 0.05,
        'Q2': 0.12,
        'Q3': -0.03,
        'Q4': 0.18,
      },
    );

    final predictive = PredictiveStrategicInsights(
      restockPredictionAlerts: [
        'BP Monitor A1 likely to stock-out in 9 days',
        'Wheelchair X2 likely to stock-out in 14 days',
      ],
      crossSellingRecommendations: {
        'Walker': ['Grip Gloves', 'Seat Cushion'],
        'BP Monitor A1': ['Spare Cuff'],
      },
      promotionsImpactUpliftPercent: {
        'Summer Sale': 22.0,
        'Doctors Day Promo': 15.0,
      },
      emergingProductDemand: [
        'Digital Stethoscope S3',
        'Smart Glucometer G2',
      ],
    );

    return ProductPartnerAnalysisData(
      demandSalesTrends: demandSales,
      inventoryInsights: inventory,
      operationalEfficiency: ops,
      customerBehaviorGeography: customer,
      revenueProfitability: revenue,
      predictiveStrategicInsights: predictive,
    );
  }
}



