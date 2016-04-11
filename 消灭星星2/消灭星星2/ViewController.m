//
//  ViewController.m
//  消灭星星2
//
//  Created by Binson on 16/1/12.
//  Copyright © 2016年 hr. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()

@property UIImageView *myView;  //游戏视图
@property UIView *starView;     //星星视图
@property UIView *stopView;     //暂停

@property NSMutableArray *arr;
//Label
@property UILabel *scoreLaber;
//音效
@property AVPlayer *pla;

@property float hit;  //星星边长
@property int score;  //得分
@property int check;  //关卡
@property int mark;   //目标分数

@property int key;
@property int num;
@property bool k;

@end

@implementation ViewController

#pragma make - 开始界面
-(void)createBegin
{
    [self createMusic:@"round_start.wav"];
    //开始背景
    UIImageView *begin = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    [begin setImage:[UIImage imageNamed:@"up_bg"]];
    [self.view addSubview:begin];
    //开始LOG
    UIImageView *start = [[UIImageView alloc]initWithFrame:CGRectMake(60, 100, 255, 200)];
    [start setImage:[UIImage imageNamed:@"title"]];
    [self.view addSubview:start];
    //开始按钮
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(100, 320, 175, 100)];
    [button setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(begin) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

#pragma make - 星星初始化
- (void)createButttonWithFrame:(CGRect)rect img:(NSString *)img tag:(NSInteger)tag
{
    UIButton *button = [[UIButton alloc]initWithFrame:rect];
    [button setTag:tag];
    [button setImage:[UIImage imageNamed:img] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(removeStar:) forControlEvents:UIControlEventTouchUpInside];
    [_starView addSubview:button];
}

#pragma make - 游戏背景
-(void)createBackground
{
    //游戏背景
    _myView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 375, 647)];
    [_myView setImage:[UIImage imageNamed:@"up_bg"]];
    [self.view addSubview:_myView];
    //放星星的View
    _starView = [[UIView alloc]initWithFrame:CGRectMake(-500, -500, 375, 375)];
    [self.view addSubview:_starView];
    [_starView setTransform:CGAffineTransformTranslate(_starView.transform, 0.1, 0.1)];
    //刷新按钮
    UIButton *newButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [newButton setFrame:CGRectMake(320, 65, 40, 40)];
    [newButton setImage:[UIImage imageNamed:@"重新开始"] forState:UIControlStateNormal];
    [newButton addTarget:self action:@selector(replace) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:newButton];
    //暂停界面
    _stopView = [[UIView alloc]initWithFrame:CGRectMake(0, 50, 375, 647)];
    UILabel *stopLabel = [[UILabel alloc]initWithFrame:CGRectMake(95, 145, 200, 50)];
    [stopLabel setText:[NSString stringWithFormat:@"休息一下"]];
    [stopLabel setFont:[UIFont fontWithName:@"Verdana-Bold" size:40]];
    [stopLabel setTextAlignment:NSTextAlignmentCenter];
    [stopLabel setTextColor:[UIColor colorWithRed:224.f/255.f green:255.f/255.f blue:255.f/255.f alpha:1]];
    [_stopView addSubview:stopLabel];
    [_stopView setHidden:YES];
    [self.view addSubview:_stopView];
    //暂停按钮
    UIButton *suspendButton = [[UIButton alloc]initWithFrame:CGRectMake(320, 25, 25, 25)];
    [suspendButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"暂停"]] forState:UIControlStateNormal ];
    suspendButton.layer.masksToBounds = YES;
    suspendButton.layer.cornerRadius = 8.0;
    [suspendButton addTarget:self action:@selector(stop:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:suspendButton];
    //关卡label
    UILabel *checkLabel = [[UILabel alloc]initWithFrame:CGRectMake(30, 23, 120, 40)];
    [checkLabel setText:[NSString stringWithFormat:@"关卡:第%d关",_check]];
    checkLabel.font = [UIFont fontWithName:@"Arial-BoldItalicMT" size:20];
    [checkLabel setTextColor:[UIColor whiteColor]];
    [self.view addSubview:checkLabel];
    //目标分数
    UILabel *markLaber = [[UILabel alloc]initWithFrame:CGRectMake(120, 55, 180, 40)];
    [markLaber setText:[NSString stringWithFormat:@"目标分数:%d",_mark]];
    markLaber.font = [UIFont fontWithName:@"AmericanTypewriter-Bold" size:20];
    [markLaber setTextColor:[UIColor whiteColor]];
    [self.view addSubview:markLaber];
    //得分label
    _scoreLaber = [[UILabel alloc]initWithFrame:CGRectMake(115, 95, 150, 50)];
    [_scoreLaber setText:[NSString stringWithFormat:@"%d",_score]];
    [_scoreLaber setFont:[UIFont fontWithName:@"Verdana-Bold" size:22]];
    [_scoreLaber setTextAlignment:NSTextAlignmentCenter];
    [_scoreLaber setTextColor:[UIColor greenColor]];
    [_scoreLaber setShadowColor:[UIColor whiteColor]];
    [self.view addSubview:_scoreLaber];
}

#pragma make - 开始游戏
- (void)begin
{
    //开始音效
    [self createMusic:@"ready_go.mp3"];
    //清除开始界面元素
    for (UIButton *button in [self.view subviews]) {
        [button removeFromSuperview];
    }
    //调用方法常见游戏背景
    [self createBackground];
    //星星按钮尺寸
    _hit = _myView.bounds.size.width/10;
    //星星产生的动画
    [UIView animateWithDuration:1.0 animations:^{
        _starView.center = CGPointMake(177.5, 450.5);
        [_starView setTransform:CGAffineTransformTranslate(_starView.transform, 10, 10)];
    }];
    for (int i=0; i<10; i++) {
        for (int j=0; j<10; j++) {
            int a = arc4random()%5+1;
            [self createButttonWithFrame:CGRectMake(0+i*_hit, 0+j*_hit, _hit, _hit) img:[NSString stringWithFormat:@"0%i",a] tag:a];
        }
    }
}

#pragma way - 消灭星星
-(void)removeStar:(UIButton *)button
{
    _arr = [[NSMutableArray alloc]init];
    [_arr addObject:button];
    //判断四周星星是否是同样的,加进数组
    for(int i =0;i<_arr.count;i++)
    {
        UIButton *btn1 = _arr[i];
        float x = btn1.frame.origin.x;
        float y = btn1.frame.origin.y;
        for(UIButton *btn2 in [_starView subviews])
        {
            float x1 = btn2.frame.origin.x;
            float y1 = btn2.frame.origin.y;
            if ((btn1.tag==btn2.tag) && ((x == x1-_hit && y == y1) || (x == x1+_hit && y==y1) || (y == y1-_hit && x==x1) || (y == y1+_hit && x==x1))) {
                if (![_arr containsObject:btn2]) {
                    [_arr addObject:btn2];
                }
            }
        }
    }
    if (_arr.count > 1) {
        for (int i=0; i<_arr.count; i++) {
            UIButton *btn3 = _arr[i];
            for (UIButton *btn4 in [_starView subviews]) {
                if ((btn3.frame.origin.x == btn4.frame.origin.x) && (btn3.frame.origin.y > btn4.frame.origin.y) && [btn4 isKindOfClass:[UIButton class]]) {
                    [UIView animateWithDuration:0.5 animations:^{
                        [btn4 setFrame:CGRectMake(btn4.frame.origin.x, btn4.frame.origin.y+_hit, _hit, _hit)];
                    }];
                }
            }
        }
        for (UIButton *btn5 in _arr) {
            [btn5 removeFromSuperview];
        }
        
        _score+= (int)_arr.count*(int)_arr.count*5;
        [_scoreLaber setText:[NSString stringWithFormat:@"%d",_score]];
        if (_score >= _mark && _check == _num) {
            [self win];
        }
    }
    if (_score >= _mark) {
        [self removeAll];
    }
    if (_arr.count >= 2 && _arr.count < 4) {
        [self createMusic:@"2ge.wav"];
    }
    if (_arr.count >= 4 && _arr.count <6) {
        [self nice];
        [self createMusic:@"nice.mp3"];
    }
    if (_arr.count >= 6 && _arr.count <8) {
        [self goodNice];
        [self createMusic:@"stage_over.wav"];
    }
    if (_arr.count >=8) {
        [self veryGood];
        [self createMusic:@"gongxi.mp3"];
    }
    //星星横移动
    NSMutableArray *arr = [NSMutableArray array];
    for(int i = 0;i < 10; i++){
        NSMutableArray *arr1 = [[NSMutableArray alloc]init];
        for(UIButton *btn6 in [_starView subviews]){
            if (btn6.frame.origin.x == _hit*i && [btn6 isKindOfClass:[UIButton class]]) {
                [arr1 addObject:btn6];
            }
        }
        [arr addObject:arr1];
    }
    for (int j = 0; j < 10; j++) {
        if ([arr[j] count] == 0) {
            for(int i = j+1; i < 10;i++ ){
                for(UIButton *btn7 in arr[i])
                {
                    [UIView animateWithDuration:0.4f animations:^{
                        [btn7 setFrame:CGRectMake(btn7.frame.origin.x-_hit, btn7.frame.origin.y, _hit, _hit)];
                    }];
                }
            }
        }
    }
    [self gameOver];
}

#pragma way - 跳关
-(void)jump
{
    if (_key == 1) {
        _mark += 2000;
        _check++;
        //[self createMusic:@"guoguan.mp3"];
        [self begin];
    }
}

#pragma make - 重新开始
-(void)replace
{
    _num = 1;
    _check = 1;
    _score = 0;
    _mark = 1000;
    [_arr removeAllObjects];
    for (id obj in [_starView subviews]) {
        [obj removeFromSuperview];
    }
    [self begin];
}

#pragma way - win
-(void)win
{
    UIImageView *winView = [[UIImageView alloc]initWithFrame:CGRectMake(135, 220, 120, 80)];
    [winView setImage:[UIImage imageNamed:@"pass1"]];
    [self.view addSubview:winView];
    [UIView animateWithDuration:2.0f animations:^{
        [winView setAlpha:0.5];
    } completion:^(BOOL finished) {
        [self createMusic:@"达到目标.wav"];
        [winView removeFromSuperview];
    }];
    _num++;
}

#pragma way - 判断相邻的星星是否还有相同的
- (void)removeAll
{
    int t=0;
    for(UIButton *btn8  in [_starView subviews]){
        float x = btn8.frame.origin.x;
        float y = btn8.frame.origin.y;
        for(UIButton *btn9 in [_starView subviews]){
            float fx = btn9.frame.origin.x;
            float fy = btn9.frame.origin.y;
            if ((btn8.tag == btn9.tag) &&  (((x == fx+_hit) && (y == fy)) || ((x == fx-_hit) && (y == fy)) || ((x == fx) && (y == fy+_hit)) ||((x == fx) && (y == fy-_hit)))) {
                t++;
            }
        }
    }
    if (t==0) {
        if (_starView.subviews.count<=10) {
            _score = _score+(2000-(int)_starView.subviews.count*200);
//            int temp = 2000-(int)_starView.subviews.count*200;
//            UILabel *jiangli = [[UILabel alloc]initWithFrame:CGRectMake(115, 150, 150, 50)];
//            [jiangli setText:[NSString stringWithFormat:@"奖励:%d",temp]];
//            [jiangli setTextColor:[UIColor redColor]];
//            [jiangli setTextAlignment:NSTextAlignmentCenter];
//            [UIView animateWithDuration:0.5f animations:^{
//                [jiangli setAlpha:0.5];
//            } completion:^(BOOL finished) {
//                [jiangli removeFromSuperview];
//            }];
            [_scoreLaber setText:[NSString stringWithFormat:@"%d",_score]];
        }
    }
//    int n=0;
//    int temp = 0;
//    if (t==0) {
//        for (UIButton *butt in [_starView subviews]) {
//            if ([butt isKindOfClass:[UIButton class]]) {
//                n++;
//            }
//            if (n<=10) {
//                temp = 2000-n*200;
//            }
//            if (n>10) {
//                temp = 0;
//            }
//            UILabel *jiangli = [[UILabel alloc]initWithFrame:CGRectMake(115, 150, 150, 50)];
//            [jiangli setText:[NSString stringWithFormat:@"奖励:%d",temp]];
//            [jiangli setTextColor:[UIColor redColor]];
//            [jiangli setTextAlignment:NSTextAlignmentCenter];
//            [UIView animateWithDuration:2.0f animations:^{
//                [jiangli setAlpha:0.5];
//            } completion:^(BOOL finished) {
//                [jiangli removeFromSuperview];
//            }];
//        }
//        _score = _score+temp;
//        [_scoreLaber setText:[NSString stringWithFormat:@"%d",_score]];
//    }
    [UIView animateWithDuration:3.0f animations:^{
        for(UIButton *butt in [_starView subviews]){
            if (t==0){
                _key=1;
                [UIView animateWithDuration:3.0f animations:^{
                    [butt setAlpha:0.2];
                } completion:^(BOOL finished) {
                    [butt removeFromSuperview];
                }];
            }
        }
    }
                    completion:^(BOOL finished){
                        if(t == 0){
                            sleep(2.0);
                            if (t==0) {
                                [self jump];
                            }
                            
                        }
                    }];
}

#pragma way - 游戏结束
-(void)gameOver
{
    int temp = 0;
    for(UIButton *butt1  in [_starView subviews]){
        float x = butt1.frame.origin.x;
        float y = butt1.frame.origin.y;
        for(UIButton *butt2 in [_starView subviews]){
            float fx = butt2.frame.origin.x;
            float fy = butt2.frame.origin.y;
            if ((butt1.tag == butt2.tag) &&  (((x == fx+_hit) && (y == fy)) || ((x == fx-_hit) && (y == fy)) || ((x == fx) && (y == fy+_hit)) ||((x == fx) && (y == fy-_hit)))) {
                temp++;
            }
        }
    }
    if(temp == 0 && _score < _mark){
        for(UIButton *butt3 in [_starView subviews]){
            [UIView animateWithDuration:2.0f animations:^{
                [butt3 setAlpha:0.2];
            } completion:^(BOOL finished) {
                
                [butt3 removeFromSuperview];
            }];
        }
        UILabel *overLabel = [[UILabel alloc]initWithFrame:CGRectMake(80, 180, 200, 80)];
        [overLabel setText:[NSString stringWithFormat:@"Game Over"]];
        [overLabel setTextAlignment:NSTextAlignmentCenter];
        [overLabel setFont:[UIFont fontWithName:@"Verdana-Bold" size:30]];
        [overLabel setTextColor:[UIColor redColor]];
        [overLabel setAlpha:0];
        [self.view addSubview:overLabel];
        UIButton *overButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [overButton setFrame:CGRectMake(130, 270, 100, 80)];
        [overButton setTitle:@"返回主菜单" forState:UIControlStateNormal];
        [overButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        [overButton setAlpha:0];
        [overButton addTarget:self action:@selector(returns) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:overButton];
        [UIView animateWithDuration:3.0f animations:^{
            [overLabel setAlpha:1.0];
        } completion:^(BOOL finished) {
            [overButton setAlpha:1.0];
        }];
    }
    if (temp == 0 && _score < _mark) {
        [self createMusic:@"game_over.wav"];
    }
}

#pragma make - 暂停
-(void)stop:(UIButton *)button
{
    _k = !_k;
    _stopView.hidden = !_stopView.hidden;
    if (_k) {
        [button setImage:[UIImage imageNamed:@"start"] forState:UIControlStateNormal];
    }else {
        [button setImage:[UIImage imageNamed:@"暂停"] forState:UIControlStateNormal];
    }
}

#pragma way - 返回主菜单
-(void)returns
{
    [self createBegin];
}

#pragma make - 弾屏动画
-(void)nice
{
    UIButton *nice=[[UIButton alloc]initWithFrame:CGRectMake(165, 160, 60, 60)];
    [nice setImage:[UIImage imageNamed:@"combo_1"] forState:(UIControlStateNormal)];
    [self.view addSubview:nice];
    [UIView animateWithDuration:0.8 animations:^{
        [nice setAlpha:0.5];
    } completion:^(BOOL finished) {
        [nice removeFromSuperview];
    }];
}

-(void)goodNice
{
    UIButton *good=[[UIButton alloc]initWithFrame:CGRectMake(165, 160, 60, 60)];
    [good setImage:[UIImage imageNamed:@"combo_2"] forState:(UIControlStateNormal)];
    [self.view addSubview:good];
    [UIView animateWithDuration:0.8 animations:^{
        [good setAlpha:0.5];
    } completion:^(BOOL finished) {
        [good removeFromSuperview];
    }];
    
}

-(void)veryGood
{
    UIButton *very=[[UIButton alloc]initWithFrame:CGRectMake(165, 160, 60, 60)];
    [very setImage:[UIImage imageNamed:@"combo_3"] forState:(UIControlStateNormal)];
    [self.view addSubview:very];
    [UIView animateWithDuration:0.8 animations:^{
        [very setAlpha:0.5];
    } completion:^(BOOL finished) {
        [very removeFromSuperview];
    }];
}

#pragma way - 添加音效
-(void)createMusic:(NSString *)string
{
    NSString *str = [[NSBundle mainBundle]pathForResource:string ofType:nil];
    NSURL *url = [[NSURL alloc]initFileURLWithPath:str];
    _pla = [[AVPlayer alloc]initWithURL:url];
    [_pla play];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _num = 1;
    _check = 1;
    _mark = 1000;
    _score = 0;
    _k = NO;
    [self createBegin];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
