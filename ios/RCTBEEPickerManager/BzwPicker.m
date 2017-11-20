//
//  BzwPicker.m
//  PickerView
//
//  Created by Bao on 15/12/14.
//  Copyright © 2015年 Microlink. All rights reserved.
//

#import "BzwPicker.h"
#define linSpace 5

@implementation BzwPicker

-(instancetype)initWithFrame:(CGRect)frame dic:(NSDictionary *)dic leftStr:(NSString *)leftStr centerStr:(NSString *)centerStr rightStr:(NSString *)rightStr topbgColor:(NSArray *)topbgColor bottombgColor:(NSArray *)bottombgColor leftbtnbgColor:(NSArray *)leftbtnbgColor rightbtnbgColor:(NSArray *)rightbtnbgColor centerbtnColor:(NSArray *)centerbtnColor selectValueArry:(NSArray *)selectValueArry  weightArry:(NSArray *)weightArry
       pickerToolBarFontSize:(NSString *)pickerToolBarFontSize  pickerFontSize:(NSString *)pickerFontSize  pickerFontColor:(NSArray *)pickerFontColor

{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backArry=[[NSMutableArray alloc]init];
        self.selectValueArry=selectValueArry;
        self.weightArry=weightArry;
        self.pickerDic=dic;
        self.leftStr=leftStr;
        self.rightStr=rightStr;
        self.centStr=centerStr;
        self.pickerToolBarFontSize=pickerToolBarFontSize;
        self.pickerFontSize=pickerFontSize;
        self.pickerFontColor=pickerFontColor;
        [self getStyle];
        [self getnumStyle];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self makeuiWith:topbgColor With:bottombgColor With:leftbtnbgColor With:rightbtnbgColor With:centerbtnColor];
            [self selectRow];
        });
    }
    return self;
}
-(void)makeuiWith:(NSArray *)topbgColor With:(NSArray *)bottombgColor With:(NSArray *)leftbtnbgColor With:(NSArray *)rightbtnbgColor With:(NSArray *)centerbtnColor
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0,0, self.frame.size.width, 40)];
    view.backgroundColor = [UIColor cyanColor];
    
    [self addSubview:view];
    
    self.leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.leftBtn.frame = CGRectMake(10, 5, 90, 30);
    [self.leftBtn setTitle:self.leftStr forState:UIControlStateNormal];
    [self.leftBtn setFont:[UIFont systemFontOfSize:[_pickerToolBarFontSize integerValue]]];
    self.leftBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self.leftBtn addTarget:self action:@selector(cancleAction) forControlEvents:UIControlEventTouchUpInside];
    
    [self.leftBtn setTitleColor:[self colorWith:leftbtnbgColor] forState:UIControlStateNormal];
    
    [view addSubview:self.leftBtn];
    
    view.backgroundColor=[self colorWith:topbgColor];
    
    self.rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.rightBtn.frame = CGRectMake(view.frame.size.width-100,5, 90, 30);
    [self.rightBtn setTitle:self.rightStr forState:UIControlStateNormal];
    self.rightBtn.contentHorizontalAlignment=UIControlContentHorizontalAlignmentRight;
    
    [self.rightBtn setTitleColor:[self colorWith:rightbtnbgColor] forState:UIControlStateNormal];
    
    [view addSubview:self.rightBtn];
    [self.rightBtn setFont:[UIFont systemFontOfSize:[_pickerToolBarFontSize integerValue]]];
    [self.rightBtn addTarget:self action:@selector(cfirmAction) forControlEvents:UIControlEventTouchUpInside];  
    
    UILabel *cenLabel=[[UILabel alloc]initWithFrame:CGRectMake(90, 5, SCREEN_WIDTH-180, 30)];
    
    cenLabel.textAlignment=NSTextAlignmentCenter;
    
    [cenLabel setFont:[UIFont systemFontOfSize:[_pickerToolBarFontSize integerValue]]];
    
    cenLabel.text=self.centStr;
    
    [cenLabel setTextColor:[self colorWith:centerbtnColor]];
    
    [view addSubview:cenLabel];

    self.pick = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 40, self.frame.size.width, self.frame.size.height - 40)];
    self.pick.delegate = self;
    self.pick.dataSource = self;
    self.pick.showsSelectionIndicator=YES;
    [self addSubview:self.pick];
    
    self.pick.backgroundColor=[self colorWith:bottombgColor];
}
//返回显示的列数
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if (_Correlation) {
        return _seleNum;
    }
    //这里是不关联的
    if (_noArryElementBool) {
        
        return 1;
        
    }else{
        
        return self.noCorreArry.count;
    }
}

#pragma mark Picker Delegate Methods


- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    if (_Correlation) {
        _lineWith=SCREEN_WIDTH-_seleNum*linSpace;
        if(self.weightArry.count>0 && self.weightArry.count==_seleNum){
            double totalweight = 0;
            for (int i = 0; i<self.weightArry.count; i++) {
                    totalweight = totalweight+[NSString stringWithFormat:@"%@",self.weightArry[i]].doubleValue;
                }
            NSString *thisweight=[NSString stringWithFormat:@"%@",self.weightArry[component]];
            return _lineWith*thisweight.doubleValue/totalweight;
            }
        else{
            return _lineWith/_seleNum;
        }
        
    }else{
        if (_noArryElementBool) {
            //表示一个数组 特殊情况
            return SCREEN_WIDTH;
        }else{
            
            _lineWith=(SCREEN_WIDTH-linSpace*(self.dataDry.count-1));
            
            if (self.weightArry.count>=self.dataDry.count) {
                
                double totalweight=0;
                
                for (NSInteger i=0; i<self.dataDry.count; i++) {
                    NSString *str=[NSString stringWithFormat:@"%@",[self.weightArry objectAtIndex:i]];
                    totalweight=totalweight+str.doubleValue;
                }
                NSString *comStr=[NSString stringWithFormat:@"%@",[self.weightArry objectAtIndex:component]];
                
                return _lineWith*comStr.doubleValue/totalweight;
            }else
            {
                if (self.weightArry.count>0) {
                    NSInteger totalNum=self.weightArry.count;
                    double totalweight=0;
                    for (NSInteger i=0; i<self.weightArry.count; i++) {
                        NSString *str=[NSString stringWithFormat:@"%@",[self.weightArry objectAtIndex:i]];
                        totalweight=totalweight+str.doubleValue;
                    }
                    if (component>totalNum-1) {
                        
                        NSString *str=[NSString stringWithFormat:@"%f",totalweight+self.dataDry.count-totalNum];
                        return _lineWith/str.doubleValue;
                    }else{
                        
                        NSString *str=[NSString stringWithFormat:@"%f",totalweight+self.dataDry.count-totalNum];
                        return _lineWith*[NSString stringWithFormat:@"%@",[self.weightArry objectAtIndex:component]].doubleValue/str.doubleValue;
                    }
                }else{
                    return _lineWith/self.dataDry.count;
                }
            }
        }
    }
}


//判断进来的类型是那种
-(void)getStyle
{
    
    self.dataDry=[self.pickerDic objectForKey:@"pickerData"];
    
    id firstobject=[self.dataDry firstObject];
    
    if ([firstobject isKindOfClass:[NSArray class]]) {
        
        _seleNum=self.dataDry.count;
        
        _Correlation=NO;
        
    }else if ([firstobject isKindOfClass:[NSDictionary class]]){
        
        //_Correlation为YES的话是关联的情况 为NO的话 是不关联的情况
        _Correlation=YES;
        
        _seleNum=[self getSelectNum];
        
    }
}
-(NSInteger)getSelectNum{
    self.dataDry=[self.pickerDic objectForKey:@"pickerData"];
    
    id firstobject=[self.dataDry firstObject];
    NSInteger i = 1;
    while ([firstobject isKindOfClass:[NSDictionary class]]) {
        NSArray * keys=[firstobject allKeys];
        firstobject=[[firstobject objectForKey:[keys firstObject]] firstObject];
        i++;
    }
    return i;
}
-(NSArray *)getCorrelationArrayWithComponent:(NSInteger)component{
    self.dataDry=[self.pickerDic objectForKey:@"pickerData"];
    NSMutableArray *arr = [NSMutableArray array];
    id selectArr;
    for (int i=0; i<=component; i++) {
        if(i==0){
            selectArr = self.dataDry;
        }else{
            NSInteger selectRow = [self.pick selectedRowInComponent:i-1];
            id selectObj=[selectArr objectAtIndex:selectRow];
            NSString *key = [[selectObj allKeys] firstObject];
            selectArr = [selectObj objectForKey:key];
        }
    }
    if([[selectArr firstObject] isKindOfClass:[NSDictionary class]]){
        for (NSDictionary *dic in selectArr) {
            [arr addObject:[[dic allKeys] firstObject]];
        }
    }else{
        return selectArr;
    }
    
    return arr;
}

//按了取消按钮
-(void)cancleAction
{
    NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
    
    if (self.backArry.count>0) {
        [dic setValue:self.backArry forKey:@"selectedValue"];
        [dic setValue:@"cancel" forKey:@"type"];
        
        [dic setValue:[self getselectIndexArry] forKey:@"selectedIndex"];
        
        self.bolock(dic);
    }else{
        [self getNOselectinfo];
        
        [dic setValue:self.backArry forKey:@"selectedValue"];
        [dic setValue:@"cancel" forKey:@"type"];
        [dic setValue:[self getselectIndexArry] forKey:@"selectedIndex"];
        self.bolock(dic);
    }
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:.2f animations:^{
            
            [self setFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 250)];
            
        }];
    });
}
//按了确定按钮
-(void)cfirmAction
{
    NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
    
    if (self.backArry.count>0) {
        
        [dic setValue:self.backArry forKey:@"selectedValue"];
        [dic setValue:@"confirm" forKey:@"type"];
        NSMutableArray *arry=[[NSMutableArray alloc]init];
        [dic setValue:[self getselectIndexArry] forKey:@"selectedIndex"];
        [dic setValue:arry forKey:@"selectedIndex"];
        
        self.bolock(dic);
        
    }else{
        [self getNOselectinfo];
        [dic setValue:self.backArry forKey:@"selectedValue"];
        [dic setValue:@"confirm" forKey:@"type"];
        
        [dic setValue:[self getselectIndexArry] forKey:@"selectedIndex"];
        
        self.bolock(dic);
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:.2f animations:^{
            
            [self setFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 250)];
        }];
    });
}
-(void)selectRow
{
    if (_Correlation) {
        //关联的一开始的默认选择行数
        [self selectValueWithCorrellation];
    }else{
        //一行的时候
        [self selectValueOne];
    }
}

-(void)selectValueWithCorrellation{
    for (int i=0; i<_seleNum; i++) {
        NSString *selectStr=[NSString stringWithFormat:@"%@",[self.selectValueArry objectAtIndex:i]];
        NSArray *currentComponentArr = [self getCorrelationArrayWithComponent:i];
        for (int j = 0; j<currentComponentArr.count; j++) {
            if([[currentComponentArr objectAtIndex:j] isEqualToString:selectStr]){
                [_pick reloadAllComponents];
                [_pick selectRow:j  inComponent:i animated:NO];
            }
        }
    }
    [_pick reloadAllComponents];
    
}

//一行时候的选择哪个的逻辑
-(void)selectValueOne
{
    if (_noArryElementBool) {
        //这里表示数组里面就只有一个数组 比较特殊的情况[]
        NSString *selectStr;
        if (self.selectValueArry.count>0) {
            
            selectStr=[NSString stringWithFormat:@"%@",[self.selectValueArry firstObject]];
        }
        for (NSInteger i=0; i<self.noCorreArry.count; i++) {
            NSString *str=[NSString stringWithFormat:@"%@",[self.noCorreArry objectAtIndex:i]];
            if ([selectStr isEqualToString:str]) {
                [_pick reloadAllComponents];
                [_pick selectRow:i  inComponent:0 animated:NO];
                break;
            }
        }
        
    }else{
        //这里就比较复杂了 [[],[],[]]
        if (self.selectValueArry.count>0) {
            
            if (self.selectValueArry.count>self.noCorreArry.count) {
                
                for (NSInteger i=0; i<self.noCorreArry.count; i++) {
                    
                    NSString *selectStr=[NSString stringWithFormat:@"%@",[self.selectValueArry objectAtIndex:i]];
                    
                    NSArray *arry=[self.noCorreArry objectAtIndex:i];
                    
                    for (NSInteger j=0; j<arry.count; j++) {
                        
                        NSString *str=[NSString stringWithFormat:@"%@",[arry objectAtIndex:j]];
                        
                        if ([selectStr isEqualToString:str]) {
                            [_pick reloadAllComponents];
                            [_pick selectRow:j inComponent:i animated:YES];
                            
                            break;
                        }
                    }
                }
            }else{
                for (NSInteger i=0; i<self.selectValueArry.count; i++) {
                    
                    NSString *selectStr=[NSString stringWithFormat:@"%@",[self.selectValueArry objectAtIndex:i]];
                    
                    NSArray *arry=[self.noCorreArry objectAtIndex:i];
                    
                    for (NSInteger j=0; j<arry.count; j++) {
                        
                        NSString *str=[NSString stringWithFormat:@"%@",[arry objectAtIndex:j]];
                        
                        if ([selectStr isEqualToString:str]) {
                            [_pick reloadAllComponents];
                            [_pick selectRow:j inComponent:i animated:YES];
                            
                            break;
                        }
                    }
                }
            }
        }
    }
}
-(void)getNOselectinfo
{
    if (_Correlation) {
        for (int i = 0; i<_seleNum; i++) {
            NSString *a=[[self getCorrelationArrayWithComponent:i] objectAtIndex:[self.pick selectedRowInComponent:i]];
            [self.backArry addObject:a];
        }
    }else
    {
        
        if (_noArryElementBool) {
            
            if (self.selectValueArry.count>0) {
                NSString *selectStr=[NSString stringWithFormat:@"%@",[self.selectValueArry firstObject]];
                [self.backArry addObject:selectStr];
            }else{
                
                [self.backArry addObject:[self.noCorreArry objectAtIndex:0]];
            }
            
        }else{
            //无关联的，直接给几个选项就行
            for (NSInteger i=0; i<self.noCorreArry.count; i++) {
                
                NSArray *eachAry=self.noCorreArry[i];
                
                [self.backArry addObject:[eachAry objectAtIndex:[self.pick selectedRowInComponent:i]]];
                
            }
        }
    }
}

-(UIColor *)colorWith:(NSArray *)colorArry
{
    NSString *ColorA=[NSString stringWithFormat:@"%@",colorArry[0]];
    NSString *ColorB=[NSString stringWithFormat:@"%@",colorArry[1]];
    NSString *ColorC=[NSString stringWithFormat:@"%@",colorArry[2]];
    NSString *ColorD=[NSString stringWithFormat:@"%@",colorArry[3]];
    
    UIColor *color=[[UIColor alloc]initWithRed:[ColorA integerValue]/255.0 green:[ColorB integerValue]/255.0 blue:[ColorC integerValue]/255.0 alpha:[ColorD floatValue]];
    return color;
}
-(NSArray *)getselectIndexArry{
    
    NSMutableArray *arry=[[NSMutableArray alloc]init];
    for (NSInteger i=0; i<_seleNum; i++) {
        NSNumber *num=[[NSNumber alloc]initWithInteger:[self.pick selectedRowInComponent:i]];
        [arry addObject:num];
        
    }
    return arry;
}

-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    
    UILabel *lbl = (UILabel *)view;
    
    if (lbl == nil) {
        lbl = [[UILabel alloc]init];
        //在这里设置字体相关属性
        lbl.font = [UIFont systemFontOfSize:[_pickerFontSize integerValue]];
        lbl.textColor = [self colorWith:_pickerFontColor];
        lbl.textAlignment = UITextAlignmentCenter;
    }
    
    //重新加载lbl的文字内容
    lbl.text = [self pickerView:pickerView titleForRow:row forComponent:component];
    
    return lbl;
    
}

















//返回当前行的内容,此处是将数组中数值添加到滚动的那个显示栏上
-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (_Correlation) {
        return [NSString stringWithFormat:@"%@",[[self getCorrelationArrayWithComponent:component] objectAtIndex:row]];
    }else{
        
        if (_noArryElementBool) {
            
            return [NSString stringWithFormat:@"%@",[self.noCorreArry objectAtIndex:row]];
            
        }else{
            return [NSString stringWithFormat:@"%@",[[self.noCorreArry objectAtIndex:component] objectAtIndex:row]];
        }
    }
    
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    if (!row) {
        row=0;
    }
    [self.backArry removeAllObjects];
    [self.infoArry removeAllObjects];
    
    if (_Correlation) {
        //这里是关联的
        for (NSInteger i = component+1; i<_seleNum; i++) {
            [pickerView reloadAllComponents];
            [pickerView selectRow:0 inComponent:i animated:YES];
        }
    }
    //返回选择的值就可以了
    
    if (_Correlation) {
        for (int i = 0; i<_seleNum; i++) {
            NSString *a=[[self getCorrelationArrayWithComponent:i] objectAtIndex:[self.pick selectedRowInComponent:i]];
            [self.backArry addObject:a];
        }
        
    }else
    {
        
        if (_noArryElementBool) {
            
            [self.backArry addObject:[self.noCorreArry objectAtIndex:row]];
            
            
        }else{
            //无关联的，直接给三个选项就行
            for (NSInteger i=0; i<self.noCorreArry.count; i++) {
                
                NSArray *eachAry=self.noCorreArry[i];
                
                [self.backArry addObject:[eachAry objectAtIndex:[self.pick selectedRowInComponent:i]]];
                
            }
        }
    }
    
    NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
    [dic setValue:self.backArry forKey:@"selectedValue"];
    
    [dic setValue:@"select" forKey:@"type"];
    
    [dic setValue:[self getselectIndexArry] forKey:@"selectedIndex"];
    if (self.backArry.count>0) {
        self.bolock(dic);
    }
}
-(void)getnumStyle{
    
    if (_Correlation) {
        
       
    }else
    {
        //这里是不关联的
        self.noCorreArry=self.dataDry;
        
        id noArryElement=[self.dataDry firstObject];
        
        if ([noArryElement isKindOfClass:[NSArray class]]) {
            
            _noArryElementBool=NO;
            
        }else{
            //这里为yes表示里面就就一行数据 表示的是只有一行的特殊情况
            _noArryElementBool=YES;
        }
    }
}


//返回当前列显示的行数
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (_Correlation) {
       return [[self getCorrelationArrayWithComponent:component] count];
    }
    
    //NSLog(@"%@",[self.noCorreArry objectAtIndex:component]);
    
    if (self.noCorreArry.count==1) {
        
        return [self.noCorreArry count];
        
    }else
    {
        
        if (_noArryElementBool) {
            
            return [self.noCorreArry count];
            
        }
        
        return  [[self.noCorreArry objectAtIndex:component] count];
    }
    
}
















@end
