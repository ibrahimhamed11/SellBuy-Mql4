//+------------------------------------------------------------------+
//|                                                    Open-sell.mq4 |
//|                                     ibrahim.hamed112@hotmail.com |
//|                          https://www.mql5.com/en/users/ibrahimht |
//+------------------------------------------------------------------+
#property strict
extern double lote=0.1;
extern int TP=30;
extern int SL=30;
extern bool UseTrailing=True;
extern bool EveryHour=False;
extern int TrailingStop=15;
input int magicNumber=20030;
extern double  Time_Period=PERIOD_H1;
extern int Stop_Time_Hour=23;
extern int Start_Time_Hour=0;

extern int Number_Of_Trades=5;
double myPoint,Buyt,Buys,Sellt,Sells;
int Ticket;
bool Opencheck;
int total;

string EaNmae="\nBy : Eng Ibrahim Hamed";
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(Digits==4||Digits<=2)
      myPoint=Point;
   if(Digits==3||Digits==5)
      myPoint=Point*10;
// int currentOpenPrice5m = Open[0];
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MTBuy()
  {
   for(int cnt=OrdersTotal()-1; cnt>=0; cnt--)
     {

      if(OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES))

         if(OrderSymbol()==Symbol())
            if(OrderType()==OP_BUY)
              {

               if(OrderOpenPrice()>OrderStopLoss())
                  if(OrderStopLoss()<Ask-(TrailingStop*myPoint))

                    {
                     OrderModify(OrderTicket(),
                                 OrderOpenPrice(),
                                 Ask-(TrailingStop*myPoint),
                                 OrderTakeProfit(),0,0);
                    }
              }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TSSell()
  {

   for(int cnt=OrdersTotal()-1; cnt>=0; cnt--)
     {

      if(OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES))

         if(OrderSymbol()==Symbol())
            if(OrderType()==OP_SELL)
              {
               if(OrderOpenPrice()<OrderStopLoss())
                 {
                  if(OrderStopLoss()>Bid+(TrailingStop*myPoint))
                    {
                     OrderModify(OrderTicket(),
                                 OrderOpenPrice(),
                                 Bid+(TrailingStop*myPoint),
                                 OrderTakeProfit(),0,0);
                    }
                 }
              }
     }
  }


//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//+------------------------------------------------------------------+
//buy check
   if(TP==0)
      Buyt=0;
   else
      Buyt=Ask+TP*myPoint;

   if(SL==0)
      Buys=0;
   else
      Buys=Ask-SL*myPoint;
//Sell Check
   if(TP==0)
      Sellt=0;
   else
      Sellt=Bid-TP*myPoint;
   if(SL==0)
      Sells=0;
   else
      Sells=Bid+SL*myPoint;

//+------------------------------------------------------------------+
//Time Hours
   int h=TimeHour(TimeCurrent());


//Tail Of previos candel
   double hight =iHigh(_Symbol,Time_Period,1);
   double low =iLow(_Symbol,Time_Period,1);

//Previos Candel boody details
   double open =iOpen(_Symbol,Time_Period,1);
   double close=iClose(_Symbol,Time_Period,1);

//Print Details
   Comment("\n\n\n\n\nHight : ",hight,
           "\n\nLow   : ",low,
           "\n\nOpen  : ",open,
           "\n\nClose : ",close,
           "\n\nHour  : ",h,

           "\n",EaNmae);
           
           
           if(EveryHour==True)
           total=24;
           else
           total=Number_Of_Trades;

   if(newBar()==true&&(h<Stop_Time_Hour&&h>Start_Time_Hour&&(Total()<total)))
     {
      
      
      
      openOrders(close,open);
      
      
      
      if(UseTrailing==true)
        {
         MTBuy();
         TSSell();
        }
     }

  }
//+------------------------------------------------------------------+
bool newBar()
  {
   static datetime Prevois_time=0;
   datetime current_time=iTime(Symbol(),Time_Period,0);
   if(Prevois_time!=current_time)
     {
      Prevois_time=current_time;
      return(true);
     }
   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int openOrders(double closeP,double openP)
  {
   if(closeP>openP)
     {
      Print("Buy Order Done");
      Ticket=OrderSend(Symbol(),OP_BUY,lote,Ask,3,Buys,Buyt,EaNmae,magicNumber,0,clrBlue);

     }
   else
     {
      Ticket=OrderSend(Symbol(),OP_SELL,lote,Bid,3,Sells,Sellt,EaNmae,magicNumber,0,clrRed);

      Print("Sell Order Done");

     }
   return 0;
  }

//+------------------------------------------------------------------+
int Total()
{
   int total=0,i;
   for(i=0; i<OrdersTotal(); i++) {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         if(Symbol()==OrderSymbol()&&OrderMagicNumber()==magicNumber) {

            total++;
         }
   }
   return(total);

}