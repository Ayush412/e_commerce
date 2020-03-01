import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class analytics extends StatefulWidget {
  @override
  _analyticsState createState() => _analyticsState();
}

class _analyticsState extends State<analytics> {

  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  int electronics=0;
  int fashion=0;
  int catTot=0;
  ProgressDialog pr;
  List<charts.Series<CategoryData, String>> catSeries = List<charts.Series<CategoryData, String>>();
  List<charts.Series<CategoryData, String>> fashSubcatSeries = List<charts.Series<CategoryData, String>>();
  List<charts.Series<CategoryData, String>> elecSubcatSeries = List<charts.Series<CategoryData, String>>();
  List<CategoryData> categoryData = List<CategoryData>();
  List fashList = ['Caps', 'Bottoms', 'Eye Wear', 'T-Shirts', 'Watches'];
  List elecList = ['Mobile Phones', 'Games', 'Laptops'];
  @override
  void initState() { 
    super.initState();
    getPieCount();
  }

  Future getViewData(String type, String value) async{
    int count=0;
    QuerySnapshot fs = await Firestore.instance.collection('products').where('$type', isEqualTo: '$value').getDocuments();
    fs.documents.forEach((f) {
      if(f.data['Views']!=null)
      count+=f.data['Views'];
    });
    categoryData.add(CategoryData(value, count));
    if(type=="SubCategory"){
      if(fashList.contains(value)){
        fashion+=count;
        fashSubcatSeries=returnList(value, fashion);
      }
      else{
        electronics+=count;
        elecSubcatSeries=returnList(value, electronics);  
    }
    }
    else{
      catTot+=count;
      catSeries=returnList(type, catTot);
    }
  }

  returnList(String id, int count){
    return [charts.Series(
        id: id,
        domainFn: (CategoryData cat, _) => cat.category,
        measureFn: (CategoryData val, _) => val.data,
        data: categoryData,
        labelAccessorFn: (CategoryData row, _) => '${row.category}: \n${((row.data/count)*100).toStringAsFixed(1)}%',
        outsideLabelStyleAccessorFn: (CategoryData val, _) => charts.TextStyleSpec(color: charts.MaterialPalette.white, fontSize: 13)
        )];
  }

  getPieCount()async{
    catTot=0;
    fashion=0;
    electronics=0;
    catSeries=[];
    fashSubcatSeries=[];
    elecSubcatSeries=[];
    categoryData=[];
    pr.show();
    await getViewData("Category", "Fashion");
    await getViewData("Category", "Electronics");
    categoryData=[];
    await getViewData("SubCategory", "Caps");
    await getViewData("SubCategory", "Bottoms");
    await getViewData("SubCategory", "Eye Wear");
    await getViewData("SubCategory", "T-Shirts");
    await getViewData("SubCategory", "Watches");
    categoryData=[];
    await getViewData("SubCategory", "Laptops");
    await getViewData("SubCategory", "Mobile Phones");
    await getViewData("SubCategory", "Games");
    pr.hide();
    setState(() {});
  }

  Widget showPie(List dataList){
    return Padding(
            padding: const EdgeInsets.only(top: 30, bottom: 20),
            child: Container(
              height: 200, 
              child: charts.PieChart(
                dataList,
                animate: true,
                animationDuration: Duration(milliseconds: 600),
                defaultRenderer: charts.ArcRendererConfig(
                  arcRendererDecorators: [
                    charts.ArcLabelDecorator(
                      labelPosition: charts.ArcLabelPosition.outside,
                    )
                  ]
                )
              ),
            )
    );
  }

  @override
  Widget build(BuildContext context) {
    pr = new ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false);
    pr.style(
      message: 'Loading...',
      borderRadius: 10.0,
      backgroundColor: Colors.white,
      progressWidget: CircularProgressIndicator(),
      elevation: 10.0,
      insetAnimCurve: Curves.easeInOut,
      progressTextStyle: TextStyle(
          color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
      messageTextStyle: TextStyle(
          color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600),
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        extendBody: true,
        appBar: AppBar(
          centerTitle: true,
          title: Text('Product Analytics', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
            color: Colors.grey,
          ),
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius:
              BorderRadius.vertical(bottom: Radius.circular(25))
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.refresh),
              color: Colors.grey,
              onPressed: () => getPieCount(),
            )
          ],
        ),
        body: Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Container(
                decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)))
              ),
            ),
            SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: Container(
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
                        child: Text('Total View Count', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),)
                      )
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top:40),
                    child: Align(child: Text('Category', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),)),
                  ),
                  showPie(catSeries),
                  Divider(
                    height: 2,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 80),
                    child: Align(child: Text('Fashion', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),)),
                  ),
                  showPie(fashSubcatSeries),
                  Padding(
                    padding: const EdgeInsets.only(top: 60),
                    child: Align(child: Text('Electronics', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),)),
                  ),
                  showPie(elecSubcatSeries)
                ],
              ),
            )
          ],
        ),
      )
    );
  }
}

class CategoryData{
  String category;
  int data;
  CategoryData(this.category, this.data);
}