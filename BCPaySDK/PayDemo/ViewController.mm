//
//  ViewController.m
//  BeeCloudDemo
//
//  Created by RInz on 15/2/5.
//  Copyright (c) 2015年 RInz. All rights reserved.
//

#import "ViewController.h"
#import "QueryResultViewController.h"

@interface ViewController ()<BCApiDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.channelTbView.delegate = self ;
    self.channelTbView.dataSource = self ;
    self.payList = @[@(WX), @(Ali), @(Union)];

    [BCPaySDK setBCApiDelegate:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [self setHideTableViewCell:self.channelTbView];
}

- (void)doPay:(PayChannel)channel {
    NSString *outTradeNo = [self genOutTradeNo];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"value",@"key", nil];
    NSLog(@"traceno = %@", outTradeNo);
    BCPayReq *payReq = [[BCPayReq alloc] init];
    payReq.channel = channel;
    payReq.title = kSubject;
    payReq.totalfee = @"1";
    payReq.billno = @"2015072321064153";// outTradeNo;
    payReq.scheme = @"payTestDemo";
    payReq.viewController = self;
    payReq.optional = dict;
    [BCPaySDK sendBCReq:payReq];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    QueryResultViewController *vc = (QueryResultViewController *)segue.destinationViewController;
    vc.dataList = self.payList;
}

- (void)onBCApiResp:(BCBaseResp *)resp {
    if ([resp isKindOfClass:[BCQueryResp class]]) {
        if (resp.result_code == 0) {
            BCQueryResp *tempResp = (BCQueryResp *)resp;
            if (tempResp.count == 0) {
                [self showAlertView:@"未找到相关订单信息"];
            } else {
                self.payList = tempResp.results;
                [self performSegueWithIdentifier:@"queryResult" sender:self];
            }
        }
    } else {
        if (resp.result_code == 0) {
             [self showAlertView:resp.result_msg];
        } else {
             [self showAlertView:resp.err_detail];
        }
    }
}

#pragma mark - 银联支付

- (void)showAlertView:(NSString *)msg {
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"提示" message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}

#pragma mark - 订单查询

- (void)doQuery:(PayChannel)channel {
    //20150722164700237
    if (self.actionType == 1) {
        BCQueryReq *req = [[BCQueryReq alloc] init];
        req.channel = channel;
        //  req.billno = @"20150722164700237";
        //  req.starttime = @"201507210000";
        // req.endtime = @"201507231200";
        req.skip = 0;
        req.limit = 20;
        [BCPaySDK sendBCReq:req];
    } else if (self.actionType == 2) {
        BCQRefundReq *req = [[BCQRefundReq alloc] init];
        req.channel = channel;
        req.skip = 0;
        req.limit = 20;
        [BCPaySDK sendBCReq:req];
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.payList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0f;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"channelCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    int channel = [[self.payList objectAtIndex:indexPath.row] intValue];
    UIImageView *imgView = (UIImageView *)[cell viewWithTag:200];
    UILabel *lab = (UILabel *)[cell viewWithTag:201];
    
    if (channel == WX) {
        imgView.image = [UIImage imageNamed:@"wxPay"];
        lab.text = @"微信支付";
    } else if (channel == Ali) {
        imgView.image = [UIImage imageNamed:@"aliPay"];
        lab.text = @"支付宝";
    } else if (channel == Union) {
        imgView.image = [UIImage imageNamed:@"uPay"];
        lab.text = @"银联在线";
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    int channel = [[self.payList objectAtIndex:indexPath.row] intValue];
    if (self.actionType == 0) {
        [self doPay:(PayChannel)channel];
    } else {
        [self doQuery:(PayChannel)channel];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (NSString *)genOutTradeNo {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmmssSSS"];
    return [formatter stringFromDate:[NSDate date]];
}

- (void)setHideTableViewCell:(UITableView *)tableView {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    tableView.tableFooterView = view;
}

@end
