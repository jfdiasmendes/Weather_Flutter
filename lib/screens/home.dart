import 'package:geolocator/geolocator.dart';
import 'package:weather/widgets/backgroundContainer.dart';
import 'package:weather/widgets/weatherCard.dart';
import 'package:weather/blocs/weather-bloc.dart';
import 'package:weather/models/customSearchDelegate.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final int hour = TimeOfDay.now().hour;
  String sDoN = 'W';
  WeatherBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = WeatherBloc();
    bloc.main();
  }

  @override
  void dispose() {
    bloc?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (hour > 6 && hour < 18)
      sDoN = 'D';
    else
      sDoN = 'N';

    return Stack(children: <Widget>[
      StreamBuilder(
        stream: bloc.getDayOrNight,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return BackgroudContainer(snapshot.data);
          } else {
            return BackgroudContainer(sDoN);
          }
        },
      ),
      CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor: Colors.transparent,
            brightness: Brightness.dark,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.refresh, color: Theme.of(context).accentColor),
              onPressed: () {
                bloc.updateWeather();
              },
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                "Weather",
                style: TextStyle(color: Theme.of(context).accentColor),
              ),
              centerTitle: true,
            ),
            actions: <Widget>[
              IconButton(
                  icon:
                      Icon(Icons.search, color: Theme.of(context).accentColor),
                  onPressed: () {
                    showSearch(
                      context: context,
                      delegate: CustomSearchDelegate(),
                    ).then((location) =>
                        location != null ? bloc.setLocation(location) : null);
                  }),
              IconButton(
                  icon:
                  Icon(Icons.add_location_outlined, color: Theme.of(context).accentColor),
                  onPressed: () {
                    bloc.main();

                  }),
            ],
          ),
          SliverToBoxAdapter(
            child: StreamBuilder(
              stream: bloc.getWeather,
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return Container();
                  default:
                    if (snapshot.hasData) {
                      return WeatherCard(snapshot.data);
                    } else {
                      return Container();
                    }
                }
              },
            ),
          ),
        ],
      )
    ]);
  }
}
