import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';

/// Represents coarse network quality states relevant for UX prompts.
enum NetworkQuality {
	online,
	poor,
	offline,
}

/// A lightweight service that monitors connectivity and approximates internet reachability.
///
/// - Uses connectivity_plus to listen for transport changes (wifi/mobile/none).
/// - Verifies actual internet access via a DNS lookup with a short timeout.
/// - Classifies "poor" when internet is reachable but latency is high.
class ConnectivityService {
	ConnectivityService._internal() {
		_listenToConnectivity();
		_startPeriodicReachabilityChecks();
	}
	static final ConnectivityService _instance = ConnectivityService._internal();
	static ConnectivityService get instance => _instance;

	final Connectivity _connectivity = Connectivity();

	final StreamController<NetworkQuality> _qualityController =
			StreamController<NetworkQuality>.broadcast();

	Stream<NetworkQuality> get qualityStream => _qualityController.stream;

	// Cache last emitted state to avoid noisy duplicate events.
	NetworkQuality? _lastEmittedQuality;

	// Periodic timer to re-validate reachability even without transport changes.
	Timer? _reachabilityTimer;

	void _listenToConnectivity() {
		_connectivity.onConnectivityChanged.listen((_) async {
			final quality = await _evaluateNetworkQuality();
			_emitIfChanged(quality);
		});
	}

	void _startPeriodicReachabilityChecks() {
		_reachabilityTimer?.cancel();
		_reachabilityTimer = Timer.periodic(const Duration(seconds: 6), (_) async {
			final quality = await _evaluateNetworkQuality();
			_emitIfChanged(quality);
		});
	}

	Future<NetworkQuality> _evaluateNetworkQuality() async {
		final connectivityResult = await _connectivity.checkConnectivity();
		if (connectivityResult == ConnectivityResult.none) {
			return NetworkQuality.offline;
		}

		// Validate real internet reachability and estimate quality by latency.
		try {
			final stopwatch = Stopwatch()..start();

			// Using a DNS lookup is a lightweight way to check external reachability.
			final lookup = await InternetAddress.lookup('google.com').timeout(
				const Duration(seconds: 2),
			);

			stopwatch.stop();

			if (lookup.isEmpty || lookup.first.rawAddress.isEmpty) {
				return NetworkQuality.offline;
			}

			// Simple heuristic: if DNS lookup took notably long, consider it "poor".
			// Tweak threshold as needed for your UX.
			if (stopwatch.elapsedMilliseconds > 1200) {
				return NetworkQuality.poor;
			}
			return NetworkQuality.online;
		} on SocketException {
			return NetworkQuality.offline;
		} on TimeoutException {
			// Transport available but timed out -> treat as poor.
			return NetworkQuality.poor;
		} catch (_) {
			// Be conservative: assume offline on unexpected failures.
			return NetworkQuality.offline;
		}
	}

	void _emitIfChanged(NetworkQuality quality) {
		if (_lastEmittedQuality != quality) {
			_lastEmittedQuality = quality;
			_qualityController.add(quality);
		}
	}

	void dispose() {
		_reachabilityTimer?.cancel();
		_qualityController.close();
	}
}


