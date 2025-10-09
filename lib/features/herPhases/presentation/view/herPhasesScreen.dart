import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../viewmodel/herPhasesViewmodel.dart';
import '../../data/models/MensuralPredictor.dart';
import '../../../../core/constants/colorpalette/ColorPalette.dart';

class HerPhasesScreen extends StatefulWidget {
  @override
  _HerPhasesScreenState createState() => _HerPhasesScreenState();
}

class _HerPhasesScreenState extends State<HerPhasesScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _dateController = TextEditingController();
  final _cycleController = TextEditingController();
  final HerPhasesViewModel _viewModel = HerPhasesViewModel();
  final ScrollController _scrollController = ScrollController();
  final _legendKey = GlobalKey();

  // Consent/contact controllers
  final _consentPhoneController = TextEditingController();
  final _consentEmailController = TextEditingController();

  Map<DateTime, String> _events = {};
  List<MensuralPredictor> _predictions = [];
  final _calendarKey = GlobalKey();

  // Focus calendar on predicted month (updated on predict)
  DateTime _focusedDay = DateTime.now();
  bool _showPredictButton = true;
  bool _isAtBottom = false;

  // Interactive legend state:
  String? _highlightedCategory; // matches event strings: "Period","Fertile",...
  bool _highlightToday = false;
  bool _showDetails = false;
  bool _consent = false;

  // Colors
  final Color periodColor = Color(0xFFFF6B6B);
  final Color prePeriodColor = Color(0xFF29B6F6);
  final Color postPeriodColor = Color(0xFF6C5CE7);
  final Color ovulationColor = Color(0xFFFFA726);
  final Color fertileColor = Color(0xFF66BB6A);
  final Color headerColor = ColorPalette.primaryColor;

  @override
  void dispose() {
    _nameController.dispose();
    _dateController.dispose();
    _cycleController.dispose();
    _scrollController.dispose();
    _consentPhoneController.dispose();
    _consentEmailController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (!_scrollController.hasClients) return;
      final double max = _scrollController.position.maxScrollExtent;
      final double pixels = _scrollController.position.pixels;
      final bool atBottom = (max - pixels) <= 24.0; // within 24px of bottom
      if (atBottom != _isAtBottom) {
        setState(() {
          _isAtBottom = atBottom;
        });
      }
    });
  }

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: headerColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _dateController.text =
        "${pickedDate.day.toString().padLeft(2, '0')}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.year}";
      });
    }
  }

  Future<void> _calculate() async {
    if (_formKey.currentState!.validate()) {
      List<MensuralPredictor> result = [];
      try {
        result = await _viewModel.submitAndPredict(
          userName: _nameController.text,
          phoneNumber: _consent ? _consentPhoneController.text.trim() : null,
          emailId: _consent && _consentEmailController.text.trim().isNotEmpty
              ? _consentEmailController.text.trim()
              : null,
          lastPeriodDate: _dateController.text,
          cycleLength: int.tryParse(_cycleController.text) ?? 28,
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit data. Please try again.'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      setState(() {
        _predictions = result;

        // NOTE: getAllEvents now needs the lastPeriodDate so it can show only that date in its month
        _events = _viewModel.getAllEvents(result, _dateController.text);

        // Decide which month/day the calendar should focus on
        _focusedDay = HerPhasesViewModel.computeFocusedDay(result, _dateController.text);

        // Reset legend highlights (optional UX choice) — keep commented if you prefer previous selection to persist
        // _highlightedCategory = null;
        // _highlightToday = false;
      });

      // Scroll to calendar once it is built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToCalendar();
      });

      // Debug print
      for (var prediction in result) {
        print("Cycle ${prediction.cycle} (${prediction.month}) Prediction for ${prediction.userName}");
        print("Cycle Start: ${prediction.cycleStartDate}");
        print("Expected Next Period: ${prediction.nextPeriodDate}");
        print("Ovulation Date: ${prediction.ovulationDate}");
        print("");
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('All mandatory fields are required.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _scrollToCalendar() {
    final context = _calendarKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        alignment: 0.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const String introText =
        "Monitoring your cycle might provide you greater insight into your periods and general health. "
        "Additionally, it might help you plan so that you are always ready.  Discover how to use our Period & Ovulation Tracker to monitor your monthly period and ovulation.\n\n"
        "Planning is made easier when periods are tracked, and ovulation days are ideal for couples attempting to conceive.";

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text("Period Tracker", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: headerColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            // Form Section
            Container(
              padding: EdgeInsets.all(20),
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Period Tracker",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      introText,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 20),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () => setState(() => _showDetails = !_showDetails),
                        icon: Icon(_showDetails ? Icons.expand_less : Icons.expand_more, color: headerColor),
                        label: Text(_showDetails ? "Show less" : "More details", style: TextStyle(color: headerColor)),
                      ),
                    ),

                    // Show details immediately below toggle (simple text, no card look)
                    AnimatedCrossFade(
                      crossFadeState: _showDetails ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                      duration: Duration(milliseconds: 200),
                      firstChild: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildQuestionBox("What is a Period Tracker?"),
                          Text(
                            "- This helps you to keep a track of your upcoming periods, to pre-plan, organise with all the essentials for your period. (the monthly shedding (bleeding) of the uterine lining that happens when pregnancy doesn't occur)\n- It gives the list of upcoming cycles to you.",
                            style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.4),
                          ),
                          SizedBox(height: 12),
                          _buildQuestionBox("What is an Ovulation Tracker?"),
                          Text(
                            " This helps you to know the ovulation time. Ovulation, which usually occurs around the middle of a cycle, is the stage of the menstrual cycle during which an egg is released from an ovary. It is the only time for conception (Conception is the biological process where a sperm cell fertilizes an egg cell, is the initial step of pregnancy)\n This is considered to be the best time for the couple, who are trying to conceive.",
                            style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.4),
                          ),
                          SizedBox(height: 12),
                          _buildQuestionBox("Details required to track your periods and know your ovulation days"),
                          Text(
                            "Last Period Start Date - This date is supposed to be the first day of your last period, for example your last month period came on 5th of January that is the 1st day of your last period.\n\nCycle Length - This is the number of days your cycles last, for example 5th January was the last period’s 1st day and 5th February is the 1st day of period, the cycle is of 31 days.\n\nFor better results keep a count of these dates and days.",
                            style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.4),
                          ),
                          SizedBox(height: 12),
                        ],
                      ),
                      secondChild: SizedBox.shrink(),
                    ),

                    _buildInputField(
                      controller: _nameController,
                      label: "Enter your name",
                      icon: Icons.person_outline,
                      validator: (value) => value?.isEmpty == true ? "Name is required" : null,
                    ),
                    SizedBox(height: 16),

                    _buildInputField(
                      controller: _dateController,
                      label: "Last period start date",
                      icon: Icons.calendar_today_outlined,
                      readOnly: true,
                      onTap: _pickDate,
                      validator: (value) => value?.isEmpty == true ? "Date is required" : null,
                    ),
                    SizedBox(height: 16),

                    _buildInputField(
                      controller: _cycleController,
                      label: "Cycle length (days)",
                      icon: Icons.repeat_outlined,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Cycle length is required";
                        }
                        final num? cycle = num.tryParse(value);
                        if (cycle == null || cycle < 20 || cycle > 40) {
                          return "Enter a valid cycle length (20–40 days)";
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 12),
                    Row(
                      children: [
                        Checkbox(
                          value: _consent,
                          activeColor: headerColor,
                          onChanged: (v) => setState(() => _consent = v ?? false),
                        ),
                        Expanded(
                          child: Text(
                            "I consent to receive helpful cycle reminders and updates.",
                            style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                          ),
                        ),
                      ],
                    ),
                    if (_consent) ...[
                      SizedBox(height: 8),
                      _buildInputField(
                        controller: _consentPhoneController,
                        label: "Phone number",
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (!_consent) return null;
                          if (value == null || value.trim().isEmpty) return "Phone is required";
                          final v = value.replaceAll(RegExp(r'[^0-9]'), '');
                          if (v.length < 10) return "Enter a valid 10-digit phone";
                          return null;
                        },
                      ),
                      SizedBox(height: 12),
                      _buildInputField(
                        controller: _consentEmailController,
                        label: "Email (optional)",
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (!_consent) return null;
                          if (value == null || value.trim().isEmpty) return null;
                          final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                          if (!emailRegex.hasMatch(value.trim())) return "Enter a valid email";
                          return null;
                        },
                      ),
                      SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _calculate,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: headerColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: Icon(Icons.analytics_outlined),
                          label: Text("Predict"),
                        ),
                      ),
                    ] else ...[
                      SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _calculate,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: headerColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            "Predict",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),


            // Calendar Section (only shown after predict)
            if (_events.isNotEmpty)
              Container(
                key: _calendarKey,
                margin: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: TableCalendar(
                    firstDay: DateTime.utc(2000, 1, 1),
                    lastDay: DateTime.utc(2100, 12, 31),

                    // show the predicted month by using _focusedDay
                    focusedDay: _focusedDay,
                    onPageChanged: (focused) {
                      setState(() {
                        _focusedDay = focused;
                      });
                    },

                    calendarFormat: CalendarFormat.month,

                    // eventLoader returns list for given day
                    eventLoader: (day) {
                      final normalized = HerPhasesViewModel.normalizeDate(day);
                      return _events.containsKey(normalized) ? [_events[normalized]!] : [];
                    },

                    // remove default dots
                    calendarStyle: CalendarStyle(
                      markersMaxCount: 0,
                      outsideDaysVisible: false,
                      weekendTextStyle: TextStyle(color: Colors.grey[800]),
                      defaultTextStyle: TextStyle(color: Colors.grey[800]),
                      cellMargin: EdgeInsets.all(6),
                      cellPadding: EdgeInsets.all(0),
                    ),

                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
                      rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
                      decoration: BoxDecoration(
                        color: headerColor,
                      ),
                      headerPadding: EdgeInsets.symmetric(vertical: 16),
                    ),

                    daysOfWeekStyle: DaysOfWeekStyle(
                      weekdayStyle: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                      weekendStyle: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),

                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, date, _) {
                        final normalized = HerPhasesViewModel.normalizeDate(date);
                        final event = _events[normalized];

                        // is today?
                        final isToday = date.year == DateTime.now().year &&
                            date.month == DateTime.now().month &&
                            date.day == DateTime.now().day;

                        if (event != null) {
                          // choose color by event type
                          Color color;
                          switch (event) {
                            case "Period":
                            case "Last Period":
                              color = periodColor;
                              break;
                            case "Pre-Period":
                              color = prePeriodColor;
                              break;
                            case "Peak Ovulation":
                              color = ovulationColor;
                              break;
                            case "Fertile":
                              color = fertileColor;
                              break;
                            case "Post Period":
                              color = postPeriodColor;
                              break;
                            default:
                              color = Colors.grey;
                          }

                          // highlighted if legend category selected
                          final bool isHighlighted = (_highlightedCategory != null && _highlightedCategory == event);

                          // if both "today highlight" and this is today - emphasize
                          final bool todayEmphasis = isToday && _highlightToday;

                          return Container(
                            margin: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: isHighlighted
                                  ? Border.all(color: headerColor, width: 3)
                                  : (todayEmphasis ? Border.all(color: headerColor, width: 2) : null),
                              boxShadow: [
                                BoxShadow(
                                  color: color.withOpacity(0.28),
                                  blurRadius: isHighlighted ? 8 : 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                '${date.day}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: isHighlighted ? 18 : 16,
                                ),
                              ),
                            ),
                          );
                        }

                        // no event for this day
                        return Container(
                          margin: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: (isToday && _highlightToday)
                                ? Border.all(color: headerColor, width: 3)
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              '${date.day}',
                              style: TextStyle(
                                color: Colors.grey[800],
                                fontSize: 16,
                                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

            // Legend Section (interactive)
            if (_events.isNotEmpty)
              Container(
                key: _legendKey,
                margin: EdgeInsets.all(16),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Legend",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildLegend(prePeriodColor, "Pre-Period", eventKey: "Pre-Period")),
                        Expanded(child: _buildLegend(periodColor, "Period", eventKey: "Period")),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildLegend(ovulationColor, "Ovulation", eventKey: "Peak Ovulation")),
                        Expanded(child: _buildLegend(fertileColor, "Fertile", eventKey: "Fertile")),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildLegend(headerColor, "Today's Date", isToday: true)),
                        const Expanded(child: SizedBox()),
                      ],
                    ),
                  ],
                ),
              ),

            // Consent Section removed (moved inline under form fields)

            // Educational Information Section (only shown after predict)
            if (_events.isNotEmpty)
              Container(
                margin: EdgeInsets.all(16),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Understanding Your Cycle",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 16),

                    _buildInfoItem(
                      color: prePeriodColor,
                      title: "Pre-Period:",
                      description: "Days just before your periods having symptoms like mood swings, food cravings, fatigue, tender breasts irritability are pre-period days.",
                    ),
                    SizedBox(height: 12),

                    _buildInfoItem(
                      color: periodColor,
                      title: "Period Days:",
                      description: "It refers to time in your menstrual cycle when you bleed (it lasts for 3 to 7 days, which is normal).",
                    ),
                    SizedBox(height: 12),

                    _buildInfoItem(
                      color: ovulationColor,
                      title: "Peak Ovulation:",
                      description: "It is the most fertile time in your menstrual cycle.",
                    ),
                    SizedBox(height: 12),

                    _buildInfoItem(
                      color: fertileColor,
                      title: "Fertile Days:",
                      description: "The five days leading up to ovulation, plus the day of ovulation and the day after ovulation significantly increases your chances of conception.",
                    ),
                  ],
                ),
              ),

            // Disclaimer Section (only after Predict)
            if (_events.isNotEmpty)
              Container(
                margin: EdgeInsets.fromLTRB(16, 0, 16, 24),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Note/ Disclaimer:",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "It is merely an estimate to use this period tracker. These findings may differ depending on your particular menstrual cycle. You must keep an eye on your body and record any changes in your cycle. You can make better judgments and obtain a better understanding of your reproductive health by doing this. Always consult your doctor or another trained healthcare professional if you have any queries about a medical problem.",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: null,
      floatingActionButton: _events.isNotEmpty
          ? FloatingActionButton(
              backgroundColor: headerColor,
              onPressed: _isAtBottom ? _scrollToTop : _scrollToLegend,
              child: Icon(_isAtBottom ? Icons.arrow_upward : Icons.arrow_downward, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildQuestionBox(String text) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      margin: EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: headerColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: headerColor,
        ),
      ),
    );
  }

  void _scrollToLegend() {
    final context = _legendKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        alignment: 0.0,
      );
    } else {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  // clickable legend helper
  Widget _buildLegend(Color color, String text, {String? eventKey, bool isToday = false}) {
    final bool isSelected = isToday ? _highlightToday : (_highlightedCategory == eventKey);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isToday) {
            _highlightToday = !_highlightToday;
          } else {
            // toggle category
            if (_highlightedCategory == eventKey) {
              _highlightedCategory = null;
            } else {
              _highlightedCategory = eventKey;
            }
          }
        });
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: isSelected ? Border.all(color: headerColor, width: 2) : null,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.25),
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? headerColor : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      validator: validator,
      style: TextStyle(fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: headerColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: headerColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildInfoItem({
    required Color color,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 18,
          height: 18,
          margin: EdgeInsets.only(top: 2),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.25),
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.4,
              ),
              children: [
                TextSpan(
                  text: title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                TextSpan(
                  text: " $description",
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Collapsible details section content
  Widget _buildDetailsSection() {
    return Container(
      margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuestionBox("What is a Period Tracker?"),
          Text(
            "- This helps you to keep a track of your upcoming periods, to pre-plan, organise with all the essentials for your period. (the monthly shedding (bleeding) of the uterine lining that happens when pregnancy doesn't occur)\n- It gives the list of upcoming cycles to you.",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
          SizedBox(height: 12),
          _buildQuestionBox("What is an Ovulation Tracker?"),
          Text(
            " This helps you to know the ovulation time. Ovulation, which usually occurs around the middle of a cycle, is the stage of the menstrual cycle during which an egg is released from an ovary. It is the only time for conception (Conception is the biological process where a sperm cell fertilizes an egg cell, is the initial step of pregnancy)\n This is considered to be the best time for the couple, who are trying to conceive.",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
          SizedBox(height: 12),
          _buildQuestionBox("Details required to track your periods and know your ovulation days"),
          Text(
            "Last Period Start Date - This date is supposed to be the first day of your last period, for example your last month period came on 5th of January that is the 1st day of your last period.\n\nCycle Length - This is the number of days your cycles last, for example 5th January was the last period’s 1st day and 5th February is the 1st day of period, the cycle is of 31 days.\n\nFor better results keep a count of these dates and days.",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
