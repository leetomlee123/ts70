import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ts70/pages/home.dart';

AppLifecycleState appLifeCycle = AppLifecycleState.resumed;

class Index extends StatefulWidget {
  const Index({super.key});

  @override
  State<StatefulWidget> createState() {
    return IndexState();
  }
}

class IndexState extends State<Index> with WidgetsBindingObserver {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this); //添加观察者
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    WidgetsBinding.instance.removeObserver(this); //添加观察者
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // appLifeCycle = state;
    switch (state) {
      case AppLifecycleState.detached:
        if (kDebugMode) {
          print('detached');
        }
        // 应用任然托管在flutter引擎上,但是不可见.
        // 当应用处于这个状态时,引擎没有视图的运行.要不就是当引擎第一次初始化时处于attach视        图中,要不就是由于导航弹出导致的视图销毁后
        break;
      case AppLifecycleState.inactive:
        if (kDebugMode) {
          print('inactive');
        }

        // 应用在一个不活跃的状态,不会收到用户的输入
        // 在ios上,这个状态相当于应用或者flutter托管的视图在前台不活跃状态运行.当有电话进来时候应用转到这个状态等
        // 在安卓上,这个状态相当于应用或者flutter托管的视图在前台不活跃状态运行.另外一个activity获得焦点时,应用转到这个状态.比如分屏,电话等
        //   在这状态的应用应该假设他们是可能被paused的.
        break;
      case AppLifecycleState.paused:
        if (kDebugMode) {
          print('paused');
        }

        //应用当前对于用户不可见,不会响应用户输入,运行在后台.

        break;
      case AppLifecycleState.resumed:
        if (kDebugMode) {
          print('resumed');
        }

        // 应用可见,响应用户输入
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Home();
  }
}
