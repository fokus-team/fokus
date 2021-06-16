import 'dart:math' as math;
import 'package:flutter/material.dart';

class DoubleCircularNotchedButton extends NotchedShape {
	const DoubleCircularNotchedButton();
	@override
	Path getOuterPath(Rect host, Rect? guest) {
		if (guest == null || !host.overlaps(guest)) return Path()..addRect(host);

		final notchRadius = guest.height / 2.0;

		const s1 = 15.0;
		const s2 = 1.0;

		final r = notchRadius;
		final a = -1.0 * r - s2;
		final b = host.top - 0;

		final n2 = math.sqrt(b * b * r * r * (a * a + b * b - r * r));
		final p2xA = ((a * r * r) - n2) / (a * a + b * b);
		final p2xB = ((a * r * r) + n2) / (a * a + b * b);
		final p2yA = math.sqrt(r * r - p2xA * p2xA);
		final p2yB = math.sqrt(r * r - p2xB * p2xB);

		///Cut-out 1
		final px = <Offset>[];

		px.add(Offset(a - s1, b));
		px.add(Offset(a, b));
		final cmpx = b < 0 ? -1.0 : 1.0;
		px.add(cmpx * p2yA > cmpx * p2yB ? Offset(p2xA, p2yA) : Offset(p2xB, p2yB));

		px.add(Offset(-1.0 * px[2].dx, px[2].dy));
		px.add(Offset(-1.0 * px[1].dx, px[1].dy));
		px.add(Offset(-1.0 * px[0].dx, px[0].dy));

		for (var i = 0; i < px.length; i += 1)
			px[i] += Offset(0 + (notchRadius + 12), 0); //Cut-out 1 positions

		///Cut-out 2
		final py = <Offset>[];

		py.add(Offset(a - s1, b));
		py.add(Offset(a, b));
		final cmpy = b < 0 ? -1.0 : 1.0;
		py.add(cmpy * p2yA > cmpy * p2yB ? Offset(p2xA, p2yA) : Offset(p2xB, p2yB));

		py.add(Offset(-1.0 * py[2].dx, py[2].dy));
		py.add(Offset(-1.0 * py[1].dx, py[1].dy));
		py.add(Offset(-1.0 * py[0].dx, py[0].dy));

		for (var i = 0; i < py.length; i += 1)
			py[i] += Offset(host.width - (notchRadius + 12), 0); //Cut-out 2 positions

		return Path()
			..moveTo(host.left, host.top)
			..lineTo(px[0].dx, px[0].dy)
			..quadraticBezierTo(px[1].dx, px[1].dy, px[2].dx, px[2].dy)
			..arcToPoint(
				px[3],
				radius: Radius.circular(notchRadius),
				clockwise: false,
			)
			..quadraticBezierTo(px[4].dx, px[4].dy, px[5].dx, px[5].dy)
			..lineTo(py[0].dx, py[0].dy)
			..quadraticBezierTo(py[1].dx, py[1].dy, py[2].dx, py[2].dy)
			..arcToPoint(
				py[3],
				radius: Radius.circular(notchRadius),
				clockwise: false,
			)
			..quadraticBezierTo(py[4].dx, py[4].dy, py[5].dx, py[5].dy)
			..lineTo(host.right, host.top)
			..lineTo(host.right, host.bottom)
			..lineTo(host.left, host.bottom)
			..close();
	}
}
