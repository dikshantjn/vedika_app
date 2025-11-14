import 'dart:async';

import 'package:flutter/material.dart';
import 'package:vedika_healthcare/shared/services/ConnectivityService.dart';
import 'package:vedika_healthcare/shared/services/GlobalKeys.dart';

/// Wraps the entire app and shows a persistent banner when offline or with poor connectivity.
class GlobalConnectivityBanner extends StatefulWidget {
	final Widget child;
	const GlobalConnectivityBanner({super.key, required this.child});

	@override
	State<GlobalConnectivityBanner> createState() => _GlobalConnectivityBannerState();
}

class _GlobalConnectivityBannerState extends State<GlobalConnectivityBanner> {
	StreamSubscription<NetworkQuality>? _subscription;
	NetworkQuality _currentQuality = NetworkQuality.online;
	NetworkQuality _previousQuality = NetworkQuality.online;
	Timer? _autoHideTimer;

	@override
	void initState() {
		super.initState();
		_subscription = ConnectivityService.instance.qualityStream.listen((quality) {
			if (!mounted) return;
			final prev = _currentQuality;
			setState(() {
				_previousQuality = _currentQuality;
				_currentQuality = quality;
			});
			_handleQualityChange(prev, quality);
		});
		// Trigger initial check
		Future<void>.microtask(() async {
			_updateBanner(_currentQuality);
		});
	}

	@override
	void dispose() {
		_autoHideTimer?.cancel();
		_subscription?.cancel();
		super.dispose();
	}

	void _handleQualityChange(NetworkQuality previous, NetworkQuality current) {
		// If we just transitioned to ONLINE from a degraded state, show a transient success banner.
		if (current == NetworkQuality.online && previous != NetworkQuality.online) {
			_showTransientSuccessBanner();
			return;
		}
		_updateBanner(current);
	}

	void _updateBanner(NetworkQuality quality) {
		final messenger = scaffoldMessengerKey.currentState;
		if (messenger == null) return;

		// Clear existing banners first to avoid duplicates.
		messenger.clearMaterialBanners();

		if (quality == NetworkQuality.online) {
			return;
		}

		final bool isPoor = quality == NetworkQuality.poor;
		final Color bg = isPoor ? Colors.orange.shade700 : Colors.red.shade700;
		final String message = isPoor
				? 'Poor network connection. Some features may not work properly.'
				: 'You appear to be offline. Please check your internet connection.';

		messenger.showMaterialBanner(
			MaterialBanner(
				backgroundColor: bg,
				elevation: 0,
				padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
				contentTextStyle: const TextStyle(
					color: Colors.white,
					fontWeight: FontWeight.w600,
				),
				dividerColor: Colors.transparent,
				leading: Icon(
					isPoor ? Icons.network_check_rounded : Icons.wifi_off_rounded,
					color: Colors.white,
				),
				content: Text(message),
				actions: <Widget>[
					TextButton(
						onPressed: () {
							// Keep the banner shown; give user a way to minimize it temporarily.
							messenger.hideCurrentMaterialBanner();
						},
						child: const Text(
							'DISMISS',
							style: TextStyle(color: Colors.white),
						),
					),
				],
			),
		);
	}

	void _showTransientSuccessBanner() {
		final messenger = scaffoldMessengerKey.currentState;
		if (messenger == null) return;

		// Cancel any pending auto-hide timer
		_autoHideTimer?.cancel();

		messenger.clearMaterialBanners();
		messenger.showMaterialBanner(
			MaterialBanner(
				backgroundColor: Colors.green.shade700,
				elevation: 0,
				padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
				contentTextStyle: const TextStyle(
					color: Colors.white,
					fontWeight: FontWeight.w600,
				),
				dividerColor: Colors.transparent,
				leading: const Icon(Icons.check_circle_rounded, color: Colors.white),
				content: const Text('You’re back online.'),
				actions: <Widget>[
					TextButton(
						onPressed: () => messenger.hideCurrentMaterialBanner(),
						child: const Text(
							'OK',
							style: TextStyle(color: Colors.white),
						),
					),
				],
			),
		);

		// Auto-hide after a short delay
		_autoHideTimer = Timer(const Duration(seconds: 2), () {
			// Ensure messenger is still valid
			messenger.hideCurrentMaterialBanner();
		});
	}

	@override
	Widget build(BuildContext context) {
		// Keep the child's layout intact; banner is injected via ScaffoldMessenger.
		return widget.child;
	}
}


