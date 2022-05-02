//
//  ViewController.m
//  FFmpegTranscoding
//
//  Created by ego on 2022/3/23.
//

#import "ViewController.h"
#import "avformat.h"
#import "ffmpeg.h"
#import "ResultViewController.h"
#import "EBDropdownListView.h"
#warning ...add
#import "TZImagePickerController.h"
#import <Photos/Photos.h>
#define kTempPath NSTemporaryDirectory()
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kHexColor(value) [UIColor colorWithRed:((float)(((value) & 0xFF0000) >> 16))/255.0 green:((float)(((value) & 0xFF00) >> 8))/255.0 blue:((float)((value) & 0xFF))/255.0 alpha:1.0]
@interface ViewController ()<TZImagePickerControllerDelegate>
@property(nonatomic,strong)UILabel *resourcesLbl;
@property(nonatomic,strong)EBDropdownListView *resourcesListView;
@property(nonatomic,copy)NSString *chooseResource;
@property(nonatomic,strong)UILabel *resolutionLbl;
@property(nonatomic,strong)EBDropdownListView *resoListView;
@property(nonatomic,copy)NSString *chooseResolution;
@property(nonatomic,strong)UILabel *fpsLbl;
@property(nonatomic,strong)EBDropdownListView *fpsListView;
@property(nonatomic,copy)NSString *chooseFps;
@property(nonatomic,strong)UILabel *encodeLbl;
@property(nonatomic,strong)UILabel *bitrateCtlLbl;
@property(nonatomic,strong)UILabel *gopLbl;
@property(nonatomic,strong)UILabel *bitrateLbl;
@property(nonatomic,strong)UIButton *h264HWBtn;
@property(nonatomic,strong)UILabel *h264HWLbl;
@property(nonatomic,strong)UIButton *h265HWBtn;
@property(nonatomic,strong)UILabel *h265HWLbl;
@property(nonatomic,strong)UIButton *x264Btn;
@property(nonatomic,strong)UILabel *x264Lbl;
@property(nonatomic,strong)UILabel *bitRateCtlLbl;
@property(nonatomic,strong)UIButton *abrBtn;
@property(nonatomic,strong)UILabel *abrLbl;
@property(nonatomic,strong)UIButton *cbrBtn;
@property(nonatomic,strong)UILabel *cbrLbl;
@property(nonatomic,strong)UILabel *goplLbl;
@property(nonatomic,strong)UIButton *x2FpsBtn;
@property(nonatomic,strong)UILabel *x2FpsLbl;
@property(nonatomic,strong)UIButton *x4FpsBtn;
@property(nonatomic,strong)UILabel *x4FpsLbl;
@property(nonatomic,strong)UILabel *coderateLbl;
@property(nonatomic,strong)UITextField *coderateTextField;
@property(nonatomic,strong)UILabel *coderateChoiceLbl;
@property(nonatomic,strong)UIButton *addBtn;
@property(nonatomic,strong)UIButton *clearBtn;
@property(nonatomic,strong)UIButton *transcodeBtn;
@property(nonatomic,strong)NSMutableArray *pathArray;
@property(nonatomic,strong)NSMutableArray *nameArray;
@property(nonatomic,assign)NSInteger startTime;
@property(nonatomic,assign)NSInteger endTime;
@property(nonatomic,strong)NSMutableArray *codecArray;
@property(nonatomic,strong)NSMutableArray *coderateArray;
@property(nonatomic,strong)NSMutableArray *abrvbrArray;
@property(nonatomic,strong)NSMutableArray *gopArray;
@property(nonatomic,strong)NSMutableArray *commandLineArray;
@end

@implementation ViewController
-(void)checkboxClick:(UIButton *)sender{
    sender.selected = !sender.selected;    
}
#warning ...add
- (void)pushTZImagePickerController {

    /*
     // If allowEditVideo is YES and allowPickingMultipleVideo is NO, When user picking a video, this callback will be called.
     // If allowPickingMultipleVideo is YES, video editing is not supported, will call imagePickerController:didFinishPickingPhotos:sourceAssets:isSelectOriginalPhoto:
     // 当allowEditVideo是YES且allowPickingMultipleVideo是NO是，如果用户选择了一个视频，下面的代理方法会被执行
     // 如果allowPickingMultipleVideo是YES，则不支持编辑视频，将会调用imagePickerController:didFinishPickingPhotos:sourceAssets:isSelectOriginalPhoto:
     */
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 columnNumber:4 delegate:self pushPhotoPickerVc:YES];
    imagePickerVc.isSelectOriginalPhoto = YES;
    imagePickerVc.allowTakePicture = NO; // 在内部显示拍照按钮
    imagePickerVc.allowTakeVideo = NO;
    imagePickerVc.allowPreview = NO;
    imagePickerVc.allowEditVideo = NO; // 允许编辑视频

    [imagePickerVc setUiImagePickerControllerSettingBlock:^(UIImagePickerController *imagePickerController) {
        imagePickerController.videoQuality = UIImagePickerControllerQualityTypeHigh;
    }];
    // imagePickerVc.autoSelectCurrentWhenDone = NO;
    
    imagePickerVc.iconThemeColor = [UIColor colorWithRed:31 / 255.0 green:185 / 255.0 blue:34 / 255.0 alpha:1.0];
    imagePickerVc.showPhotoCannotSelectLayer = YES;
    imagePickerVc.cannotSelectLayerColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
    
    // 3. Set allow picking video & photo & originalPhoto or not
    // 3. 设置是否可以选择视频/图片/原图
    imagePickerVc.allowPickingVideo = YES;
    imagePickerVc.allowPickingImage = NO;
    imagePickerVc.allowPickingOriginalPhoto = YES;
    imagePickerVc.allowPickingGif = NO;
    imagePickerVc.allowPickingMultipleVideo = NO; // 是否可以多选视频
    
    // 4. 照片排列按修改时间升序
    imagePickerVc.sortAscendingByModificationDate = YES;
    
    imagePickerVc.showSelectBtn = NO;
    imagePickerVc.allowCrop = NO;
    imagePickerVc.needCircleCrop = NO;
    
    imagePickerVc.statusBarStyle = UIStatusBarStyleLightContent;
    
    // 设置是否显示图片序号
    imagePickerVc.showSelectedIndex = YES;
    
    imagePickerVc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingVideo:(UIImage *)coverImage sourceAssets:(PHAsset *)asset {
    // open this code to send video / 打开这段代码发送视频
    [[TZImageManager manager] getVideoOutputPathWithAsset:asset presetName:AVAssetExportPresetHighestQuality success:^(NSString *outputPath) {
        // NSData *data = [NSData dataWithContentsOfFile:outputPath];
        NSLog(@"视频导出到本地完成,沙盒路径为:%@",outputPath);
        self.chooseResource = [kTempPath stringByAppendingFormat:@"%@", outputPath.lastPathComponent];
        self.resourcesListView.textLabel.text = outputPath.lastPathComponent;
        NSLog(@"chooseResource = %@",self.chooseResource);

        NSLog(@"end");
        // Export completed, send video here, send by outputPath or NSData
        // 导出完成，在这里写上传代码，通过路径或者通过NSData上传
    } failure:^(NSString *errorMessage, NSError *error) {
        NSLog(@"视频导出失败:%@,error:%@",errorMessage, error);
    }];
}
-(void)initUI{
    self.resourcesLbl = [[UILabel alloc]initWithFrame:CGRectMake(2, 100, kScreenWidth, 30)];
    self.resourcesLbl.font = [UIFont fontWithName:@"PingFangSC-regular" size:15];
    self.resourcesLbl.textColor = kHexColor(0x999999);
    self.resourcesLbl.textAlignment = NSTextAlignmentLeft;
    self.resourcesLbl.text = @"选择数据源";
    [self.view addSubview:self.resourcesLbl];
    
    self.codecArray = [NSMutableArray array];
    self.coderateArray = [NSMutableArray array];
    self.abrvbrArray = [NSMutableArray array];
    self.gopArray = [NSMutableArray array];
    self.commandLineArray = [NSMutableArray array];
    //选择资源
    NSMutableArray *itemArray = [NSMutableArray array];
    for (int i=0; i<self.pathArray.count; i++) {
        EBDropdownListItem *item = [[EBDropdownListItem alloc] initWithItem:self.pathArray[i] itemName:self.nameArray[i]];
        [itemArray addObject:item];
    }
    // 弹出框向上
    self.resourcesListView = [[EBDropdownListView alloc] initWithDataSource:itemArray];

    self.resourcesListView.frame = CGRectMake(2, CGRectGetMaxY(self.resourcesLbl.frame)+2, kScreenWidth, 30);
    self.resourcesListView.selectedIndex = 2;
    [self.resourcesListView setViewBorder:0.5 borderColor:[UIColor grayColor] cornerRadius:2];
    [self.view addSubview:self.resourcesListView];
    
    __weak typeof(self) weakSelf = self;
    [self.resourcesListView setDropdownListViewSelectedBlock:^(EBDropdownListView *dropdownListView) {
        NSString *name = dropdownListView.selectedItem.itemName;
#warning ...add
        if ([name isEqualToString:@"相册"]) {
            [weakSelf pushTZImagePickerController];
        }
        else {
        weakSelf.chooseResource = dropdownListView.selectedItem.itemName;
        NSLog(@"选择了资源文件:%@",weakSelf.chooseResource);
        NSString *msgString = [NSString stringWithFormat:
                               @"selected name:%@  id:%@  index:%ld"
                               , dropdownListView.selectedItem.itemName
                               , dropdownListView.selectedItem.itemId
                               , dropdownListView.selectedIndex];
        NSLog(@"选择了:%@",msgString);
        }
    }];
    
    self.resolutionLbl = [[UILabel alloc]initWithFrame:CGRectMake(2, CGRectGetMaxY(self.resourcesListView.frame)+2, kScreenWidth, 30)];
    self.resolutionLbl.font = [UIFont fontWithName:@"PingFangSC-regular" size:15];
    self.resolutionLbl.textColor = kHexColor(0x999999);
    self.resolutionLbl.textAlignment = NSTextAlignmentLeft;
    self.resolutionLbl.text = @"分辨率";
    [self.view addSubview:self.resolutionLbl];
    
    EBDropdownListItem *item1 = [[EBDropdownListItem alloc] initWithItem:@"1" itemName:@"720x1280"];
    EBDropdownListItem *item2 = [[EBDropdownListItem alloc] initWithItem:@"2" itemName:@"540x960"];
    EBDropdownListItem *item3 = [[EBDropdownListItem alloc] initWithItem:@"3" itemName:@"360x640"];
    EBDropdownListItem *item4 = [[EBDropdownListItem alloc] initWithItem:@"4" itemName:@"180x320"];
    // 弹出框向上
    self.resoListView = [[EBDropdownListView alloc] initWithDataSource:@[item1, item2, item3, item4]];
    self.resoListView.frame = CGRectMake(2, CGRectGetMaxY(self.resolutionLbl.frame)+2, kScreenWidth, 30);
    self.resoListView.selectedIndex = 2;
    [self.resoListView setViewBorder:0.5 borderColor:[UIColor grayColor] cornerRadius:2];
    [self.view addSubview:self.resoListView];
    
    [self.resoListView setDropdownListViewSelectedBlock:^(EBDropdownListView *dropdownListView) {
        weakSelf.chooseResolution = dropdownListView.selectedItem.itemName;
        NSLog(@"选择了分辨率:%@",weakSelf.chooseResolution);
        NSString *msgString = [NSString stringWithFormat:
                               @"selected name:%@  id:%@  index:%ld"
                               , dropdownListView.selectedItem.itemName
                               , dropdownListView.selectedItem.itemId
                               , dropdownListView.selectedIndex];
        NSLog(@"选择了:%@",msgString);
        
    }];
    
    self.fpsLbl = [[UILabel alloc]initWithFrame:CGRectMake(2, CGRectGetMaxY(self.resoListView.frame), kScreenWidth, 30)];
    self.fpsLbl.font = [UIFont fontWithName:@"PingFangSC-regular" size:15];
    self.fpsLbl.textColor = kHexColor(0x999999);
    self.fpsLbl.textAlignment = NSTextAlignmentLeft;
    self.fpsLbl.text = @"帧率";
    [self.view addSubview:self.fpsLbl];
    
    EBDropdownListItem *item5 = [[EBDropdownListItem alloc] initWithItem:@"1" itemName:@"30"];
    EBDropdownListItem *item6 = [[EBDropdownListItem alloc] initWithItem:@"2" itemName:@"24"];
    EBDropdownListItem *item7 = [[EBDropdownListItem alloc] initWithItem:@"3" itemName:@"15"];
    EBDropdownListItem *item8 = [[EBDropdownListItem alloc] initWithItem:@"4" itemName:@"12"];
    EBDropdownListItem *item9 = [[EBDropdownListItem alloc] initWithItem:@"5" itemName:@"10"];
    EBDropdownListItem *item10 = [[EBDropdownListItem alloc] initWithItem:@"6" itemName:@"8"];
    // 弹出框向上
    self.fpsListView = [[EBDropdownListView alloc] initWithDataSource:@[item5, item6, item7, item8,item9,item10]];
    self.fpsListView.frame = CGRectMake(2, CGRectGetMaxY(self.fpsLbl.frame)+2, kScreenWidth, 30);
    self.fpsListView.selectedIndex = 2;
    [self.fpsListView setViewBorder:0.5 borderColor:[UIColor grayColor] cornerRadius:2];
    [self.view addSubview:self.fpsListView];
    
    [self.fpsListView setDropdownListViewSelectedBlock:^(EBDropdownListView *dropdownListView) {
        weakSelf.chooseFps = dropdownListView.selectedItem.itemName;
        NSLog(@"选择了帧率:%@",weakSelf.chooseFps);
        NSString *msgString = [NSString stringWithFormat:
                               @"selected name:%@  id:%@  index:%ld"
                               , dropdownListView.selectedItem.itemName
                               , dropdownListView.selectedItem.itemId
                               , dropdownListView.selectedIndex];
        NSLog(@"选择了:%@",msgString);
        
    }];
    
    self.encodeLbl = [[UILabel alloc]initWithFrame:CGRectMake(2, CGRectGetMaxY(self.fpsListView.frame)+2, kScreenWidth, 30)];
    self.encodeLbl.font = [UIFont fontWithName:@"PingFangSC-regular" size:15];
    self.encodeLbl.textColor = kHexColor(0x999999);
    self.encodeLbl.textAlignment = NSTextAlignmentLeft;
    self.encodeLbl.text = @"编码器";
    [self.view addSubview:self.encodeLbl];
    
    self.h264HWBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.h265HWBtn.tag = 100;
    CGRect checkboxRect = CGRectMake(2,CGRectGetMaxY(self.encodeLbl.frame),32,32);
    [self.h264HWBtn setFrame:checkboxRect];
    [self.h264HWBtn setImage:[UIImage imageNamed:@"select_n.png"] forState:UIControlStateNormal];
    [self.h264HWBtn setImage:[UIImage imageNamed:@"select_s.png"] forState:UIControlStateSelected];
    [self.h264HWBtn addTarget:self action:@selector(checkboxClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.h264HWBtn];
    
    self.h264HWLbl = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.h264HWBtn.frame), CGRectGetMaxY(self.encodeLbl.frame), 68, 30)];
    self.h264HWLbl.font = [UIFont fontWithName:@"PingFangSC-regular" size:15];
    self.h264HWLbl.textColor = kHexColor(0x999999);
    self.h264HWLbl.textAlignment = NSTextAlignmentLeft;
    self.h264HWLbl.text = @"h264HW";
    [self.view addSubview:self.h264HWLbl];
    
    self.h265HWBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.h265HWBtn.tag = 101;
    CGRect checkboxRect1 = CGRectMake(CGRectGetMaxX(self.h264HWLbl.frame),CGRectGetMaxY(self.encodeLbl.frame),32,32);
    [self.h265HWBtn setFrame:checkboxRect1];
    [self.h265HWBtn setImage:[UIImage imageNamed:@"select_n.png"] forState:UIControlStateNormal];
    [self.h265HWBtn setImage:[UIImage imageNamed:@"select_s.png"] forState:UIControlStateSelected];
    [self.h265HWBtn addTarget:self action:@selector(checkboxClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.h265HWBtn];
    
    self.h265HWLbl = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.h265HWBtn.frame), CGRectGetMaxY(self.encodeLbl.frame), 68, 30)];
    self.h265HWLbl.font = [UIFont fontWithName:@"PingFangSC-regular" size:15];
    self.h265HWLbl.textColor = kHexColor(0x999999);
    self.h265HWLbl.textAlignment = NSTextAlignmentLeft;
    self.h265HWLbl.text = @"h265HW";
    [self.view addSubview:self.h265HWLbl];
    
    self.x264Btn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.x264Btn.tag = 102;
    CGRect checkboxRect2 = CGRectMake(CGRectGetMaxX(self.h265HWLbl.frame),CGRectGetMaxY(self.encodeLbl.frame),32,32);
    [self.x264Btn setFrame:checkboxRect2];
    [self.x264Btn setImage:[UIImage imageNamed:@"select_n.png"] forState:UIControlStateNormal];
    [self.x264Btn setImage:[UIImage imageNamed:@"select_s.png"] forState:UIControlStateSelected];
    [self.x264Btn addTarget:self action:@selector(checkboxClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.x264Btn];
    
    self.x264Lbl = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.x264Btn.frame), CGRectGetMaxY(self.encodeLbl.frame), 120, 30)];
    self.x264Lbl.font = [UIFont fontWithName:@"PingFangSC-regular" size:15];
    self.x264Lbl.textColor = kHexColor(0x999999);
    self.x264Lbl.textAlignment = NSTextAlignmentLeft;
    self.x264Lbl.text = @"x264LowBitrate";
    [self.view addSubview:self.x264Lbl];
    
    self.bitRateCtlLbl = [[UILabel alloc]initWithFrame:CGRectMake(2, CGRectGetMaxY(self.x264Lbl.frame), 68, 30)];
    self.bitRateCtlLbl.font = [UIFont fontWithName:@"PingFangSC-regular" size:15];
    self.bitRateCtlLbl.textColor = kHexColor(0x999999);
    self.bitRateCtlLbl.textAlignment = NSTextAlignmentLeft;
    self.bitRateCtlLbl.text = @"码率控制";
    [self.view addSubview:self.bitRateCtlLbl];
    
    self.abrBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.abrBtn.tag = 104;
    CGRect checkboxRect3 = CGRectMake(2,CGRectGetMaxY(self.bitRateCtlLbl.frame),32,32);
    [self.abrBtn setFrame:checkboxRect3];
    [self.abrBtn setImage:[UIImage imageNamed:@"select_n.png"] forState:UIControlStateNormal];
    [self.abrBtn setImage:[UIImage imageNamed:@"select_s.png"] forState:UIControlStateSelected];
    [self.abrBtn addTarget:self action:@selector(checkboxClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.abrBtn];
    
    self.abrLbl = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.abrBtn.frame), CGRectGetMaxY(self.bitRateCtlLbl.frame), 68, 30)];
    self.abrLbl.font = [UIFont fontWithName:@"PingFangSC-regular" size:15];
    self.abrLbl.textColor = kHexColor(0x999999);
    self.abrLbl.textAlignment = NSTextAlignmentLeft;
    self.abrLbl.text = @"ABR";
    [self.view addSubview:self.abrLbl];
    
    self.cbrBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.cbrBtn.tag = 105;
    CGRect checkboxRect4 = CGRectMake(CGRectGetMaxX(self.abrLbl.frame),CGRectGetMaxY(self.bitRateCtlLbl.frame),32,32);
    [self.cbrBtn setFrame:checkboxRect4];
    [self.cbrBtn setImage:[UIImage imageNamed:@"select_n.png"] forState:UIControlStateNormal];
    [self.cbrBtn setImage:[UIImage imageNamed:@"select_s.png"] forState:UIControlStateSelected];
    [self.cbrBtn addTarget:self action:@selector(checkboxClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.cbrBtn];
    
    self.cbrLbl = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.cbrBtn.frame), CGRectGetMaxY(self.bitRateCtlLbl.frame), 68, 30)];
    self.cbrLbl.font = [UIFont fontWithName:@"PingFangSC-regular" size:15];
    self.cbrLbl.textColor = kHexColor(0x999999);
    self.cbrLbl.textAlignment = NSTextAlignmentLeft;
    self.cbrLbl.text = @"CBR";
    [self.view addSubview:self.cbrLbl];
    
    self.gopLbl = [[UILabel alloc]initWithFrame:CGRectMake(2, CGRectGetMaxY(self.cbrLbl.frame), 68, 30)];
    self.gopLbl.font = [UIFont fontWithName:@"PingFangSC-regular" size:15];
    self.gopLbl.textColor = kHexColor(0x999999);
    self.gopLbl.textAlignment = NSTextAlignmentLeft;
    self.gopLbl.text = @"GOP";
    [self.view addSubview:self.gopLbl];
    
    self.x2FpsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.x2FpsBtn.tag = 106;
    CGRect checkboxRect5 = CGRectMake(2,CGRectGetMaxY(self.gopLbl.frame),32,32);
    [self.x2FpsBtn setFrame:checkboxRect5];
    [self.x2FpsBtn setImage:[UIImage imageNamed:@"select_n.png"] forState:UIControlStateNormal];
    [self.x2FpsBtn setImage:[UIImage imageNamed:@"select_s.png"] forState:UIControlStateSelected];
    [self.x2FpsBtn addTarget:self action:@selector(checkboxClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.x2FpsBtn];
    
    self.x2FpsLbl = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.x2FpsBtn.frame), CGRectGetMaxY(self.gopLbl.frame), 68, 30)];
    self.x2FpsLbl.font = [UIFont fontWithName:@"PingFangSC-regular" size:15];
    self.x2FpsLbl.textColor = kHexColor(0x999999);
    self.x2FpsLbl.textAlignment = NSTextAlignmentLeft;
    self.x2FpsLbl.text = @"2xFPS";
    [self.view addSubview:self.x2FpsLbl];
    
    self.x4FpsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.x4FpsBtn.tag = 107;
    CGRect checkboxRect6 = CGRectMake(CGRectGetMaxX(self.x2FpsLbl.frame),CGRectGetMaxY(self.gopLbl.frame),32,32);
    [self.x4FpsBtn setFrame:checkboxRect6];
    [self.x4FpsBtn setImage:[UIImage imageNamed:@"select_n.png"] forState:UIControlStateNormal];
    [self.x4FpsBtn setImage:[UIImage imageNamed:@"select_s.png"] forState:UIControlStateSelected];
    [self.x4FpsBtn addTarget:self action:@selector(checkboxClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.x4FpsBtn];
    
    self.x4FpsLbl = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.x4FpsBtn.frame), CGRectGetMaxY(self.gopLbl.frame), 68, 30)];
    self.x4FpsLbl.font = [UIFont fontWithName:@"PingFangSC-regular" size:15];
    self.x4FpsLbl.textColor = kHexColor(0x999999);
    self.x4FpsLbl.textAlignment = NSTextAlignmentLeft;
    self.x4FpsLbl.text = @"4xFPS";
    [self.view addSubview:self.x4FpsLbl];
    
    self.coderateLbl = [[UILabel alloc]initWithFrame:CGRectMake(2, CGRectGetMaxY(self.x4FpsLbl.frame), 68, 30)];
    self.coderateLbl.font = [UIFont fontWithName:@"PingFangSC-regular" size:15];
    self.coderateLbl.textColor = kHexColor(0x999999);
    self.coderateLbl.textAlignment = NSTextAlignmentLeft;
    self.coderateLbl.text = @"码率";
    [self.view addSubview:self.coderateLbl];
    
    self.coderateChoiceLbl = [[UILabel alloc]initWithFrame:CGRectMake(2, CGRectGetMaxY(self.coderateLbl.frame), kScreenWidth-4, 30)];
    self.coderateChoiceLbl.font = [UIFont fontWithName:@"PingFangSC-regular" size:15];
    self.coderateChoiceLbl.textColor = kHexColor(0x999999);
    self.coderateChoiceLbl.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:self.coderateChoiceLbl];
    
    self.coderateTextField = [[UITextField alloc] init];
    self.coderateTextField.frame = CGRectMake(2, CGRectGetMaxY(self.coderateChoiceLbl.frame), 200, 40);
    self.coderateTextField.textAlignment = NSTextAlignmentLeft;
    self.coderateTextField.font = [UIFont fontWithName:@"PingFangSC-regular" size:16];
    self.coderateTextField.textColor = [UIColor blackColor];
    // 就下面这两行是重点
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:@"请输入码率，单位kbps" attributes:
    @{NSForegroundColorAttributeName:[UIColor redColor],
                 NSFontAttributeName:self.coderateTextField.font
         }];
    self.coderateTextField.attributedPlaceholder = attrString;
    [self.view addSubview:self.coderateTextField];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(2, CGRectGetMaxY(self.coderateTextField.frame), 200, 1)];
    lineView.backgroundColor = [UIColor cyanColor];
    [self.view addSubview:lineView];
    
    UITapGestureRecognizer *t = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self.view addGestureRecognizer:t];
    
    self.addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.addBtn.frame = CGRectMake(CGRectGetMaxX(self.coderateTextField.frame)+2,CGRectGetMaxY(self.coderateChoiceLbl.frame),60,32);
    self.addBtn.layer.cornerRadius = 5;
    [self.addBtn setTitle:@"添加" forState:UIControlStateNormal];
    self.addBtn.backgroundColor = [UIColor blueColor];
    [self.addBtn addTarget:self action:@selector(addClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.addBtn];
    
    self.clearBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.clearBtn.frame = CGRectMake(CGRectGetMaxX(self.addBtn.frame)+2,CGRectGetMaxY(self.coderateChoiceLbl.frame),60,32);
    self.clearBtn.layer.cornerRadius = 5;
    [self.clearBtn setTitle:@"清空" forState:UIControlStateNormal];
    self.clearBtn.backgroundColor = [UIColor blueColor];
    [self.clearBtn addTarget:self action:@selector(clearClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.clearBtn];
    
    self.transcodeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.transcodeBtn.frame = CGRectMake(0,CGRectGetMaxY(self.coderateTextField.frame)+36,kScreenWidth,32);
    self.transcodeBtn.layer.cornerRadius = 5;
    [self.transcodeBtn setTitle:@"开始转码" forState:UIControlStateNormal];
    self.transcodeBtn.backgroundColor = [UIColor blueColor];
    [self.transcodeBtn addTarget:self action:@selector(transcodeClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.transcodeBtn];
}
-(void)transcodeClick:(UIButton *)sender{
    //编码器选择
    if(self.h264HWBtn.selected == YES){
        [self.codecArray addObject:@"h264HW"];
    }
    if(self.x264Btn.selected == YES){
        [self.codecArray addObject:@"x264"];
    }
    if (self.h265HWBtn.selected == YES) {
        [self.codecArray addObject:@"h265HW"];
    }
    if (self.codecArray.count == 0) {
        [self showAlert:@"请选择编码器"];
        return;
    }
    //码率控制
    if (self.abrBtn.selected == YES){
        [self.abrvbrArray addObject:@"abr"];
    }
    if(self.cbrBtn.selected == YES) {
        [self.abrvbrArray addObject:@"cbr"];
    }
    //GOP选择
    if (self.x2FpsBtn.selected == YES){
        if (self.chooseFps == nil || self.chooseFps.length == 0) {
            [self showAlert:@"请选择分辨率"];
            return;
        }
        [self.gopArray addObject:@"gop_2fps"];
    }
    if(self.x4FpsBtn.selected == YES) {
        if (self.chooseFps == nil || self.chooseFps.length == 0) {
            [self showAlert:@"请选择分辨率"];
            return;
        }
        [self.gopArray addObject:@"gop_4fps"];
    }
    self.startTime = [self currentDateInterval];
    [self ffmpegTest];
}
-(void)showAlert:(NSString *)message{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"点击了Cancel");
        return;
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"点击了OK");
        return;
    }];
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}
-(void)addClick:(UIButton *)sender{
    if (self.coderateTextField.text.length == 0) {
        [self showAlert:@"请输入码率"];
        return;
    }
    [self.coderateArray addObject:self.coderateTextField.text];
    self.coderateTextField.text = @"";
    NSMutableString *choiceCoderate = [NSMutableString stringWithCapacity:200];
    for (NSString *str in self.coderateArray) {
        [choiceCoderate appendString:[NSString stringWithFormat:@"%@ ",str]];
        NSLog(@"%@",choiceCoderate);
    }
    self.coderateChoiceLbl.text = choiceCoderate;
}
-(void)clearClick:(UIButton *)sender{
    self.coderateTextField.text = @"";
    [self.coderateArray removeAllObjects];
    self.coderateChoiceLbl.text = @"";
}
-(void)tap:(UITapGestureRecognizer *)tap{
    [self.view endEditing:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    //ffmpeg版本
    const char *s = av_version_info();
    printf("ffmpeg版本:%s\n",s);
    av_register_all();
    
    self.title = @"FFmpegTranscoding";
    [self getResources];
    
    [self initUI];
    
//    [self ffmpegMp4libx264];
//    [self ffmpegtest];
//    [self ffmpegtestMovToMp4Two];
//    [self ffmpegMp4VideoToolBox];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.codecArray removeAllObjects];
    //返回后码率需要手动清空
//    [self.coderateArray removeAllObjects];
    [self.abrvbrArray removeAllObjects];
    [self.gopArray removeAllObjects];
    [self.commandLineArray removeAllObjects];
    NSLog(@"参数清空");
}
-(NSString *)currentDateString{
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYYMMdd_hhmmss"];
    NSString *dateTime = [formatter stringFromDate:date];
    NSLog(@"============年月日_时分秒=====================%@",dateTime);
    return dateTime;
}
-(NSInteger)currentDateInterval{
    NSDate *dateNow = [NSDate date];
    NSString *timeSp = [NSString stringWithFormat:@"%ld",(long)([dateNow timeIntervalSince1970]*1000)];
    return timeSp.integerValue;
}
-(void)ffmpegTest
{
    NSMutableString *commandLineString = [NSMutableString stringWithCapacity:200];
    for (int i=0; i<self.codecArray.count; i++) {
        //没有填写码率
        if (self.coderateArray.count == 0) {
            //gop没有勾选
            if (self.gopArray.count == 0) {
                commandLineString = [self assembleCommandLineWithCodec:self.codecArray[i] withCodeRate:nil withAbrOrVbr:nil withGop:nil];
            }else{
                for (int n = 0; n<self.gopArray.count; n++) {
                    commandLineString = [self assembleCommandLineWithCodec:self.codecArray[i] withCodeRate:nil withAbrOrVbr:nil withGop:self.gopArray[n]];
                    [self.commandLineArray addObject:commandLineString.copy];
                }
            }
            
        }else{//填写了码率
            for (int j=0; j<self.coderateArray.count; j++) {
                for (int k=0; k<self.abrvbrArray.count; k++) {
                    if (self.gopArray.count == 0) {
                        commandLineString = [self assembleCommandLineWithCodec:self.codecArray[i] withCodeRate:self.coderateArray[j] withAbrOrVbr:self.abrvbrArray[k] withGop:nil];
                        [self.commandLineArray addObject:commandLineString.copy];
                    }
                    else{
                        for (int m = 0; m<self.gopArray.count; m++) {
                            commandLineString = [self assembleCommandLineWithCodec:self.codecArray[i] withCodeRate:self.coderateArray[j] withAbrOrVbr:self.abrvbrArray[k] withGop:self.gopArray[m]];
                            [self.commandLineArray addObject:commandLineString.copy];
                        }
                    }
                    NSLog(@"有码率最终命令行个数:%ld",self.commandLineArray.count);
                }
            }
        }
        if (![self.commandLineArray containsObject:commandLineString.copy]) {
            [self.commandLineArray addObject:commandLineString.copy];
            NSLog(@"没有码率最终命令行个数:%ld",self.commandLineArray.count);
        }
    }
    [self ffmpegCommandLine:self.commandLineArray.firstObject];
}
-(NSMutableString *)assembleCommandLineWithCodec:(NSString *)codec withCodeRate:(NSString *)coderate withAbrOrVbr:(NSString *)br withGop:(NSString *)gop{
    //获取选择的资源文件
    //防止选择文件为空
    if (self.chooseResource == nil || self.chooseResource.length == 0) {
        self.chooseResource = @"MyHeartWillGoOn.mp4";
    }
    //源文件名
    NSString *fromFile = [[NSBundle mainBundle]pathForResource:self.chooseResource ofType:nil];
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    //目标文件名
    NSString *toFile = self.chooseResource;
#warning ...add
    if (fromFile == nil) {
        NSLog(@"这是从相册读取视频文件的,所以用Bundle的方法会是nil");
        fromFile = self.chooseResource;
        self.chooseResource = [self.chooseResource lastPathComponent];
    }
    // 分割字符串
    NSMutableArray  *video_array  = [self.chooseResource componentsSeparatedByString:(@".")].mutableCopy;
    
    if(coderate && coderate.length > 0){
        if (br && br.length > 0) {
            if (gop && gop.length > 0) {
                toFile = [documentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@_%@_%@_%@_%@.%@",video_array.firstObject,codec,coderate,br,[NSString stringWithFormat:@"%@*%@",gop,self.chooseFps],[self currentDateString],video_array.lastObject]];
            }else
            toFile = [documentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@_%@_%@_%@.%@",video_array.firstObject,codec,coderate,br,[self currentDateString],video_array.lastObject]];
        }else
            if (gop && gop.length > 0) {
                toFile = [documentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@_%@_%@_%@.%@",video_array.firstObject,codec,coderate,[NSString stringWithFormat:@"%@*%@",gop,self.chooseFps],[self currentDateString],video_array.lastObject]];
            }
            else
        toFile = [documentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@_%@_%@.%@",video_array.firstObject,codec,coderate,[self currentDateString],video_array.lastObject]];
    }else{
        if (gop && gop.length > 0) {
            toFile = [documentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@_%@_%@.%@",video_array.firstObject,codec,[NSString stringWithFormat:@"%@*%@",gop,self.chooseFps],[self currentDateString],video_array.lastObject]];
        }
        toFile = [documentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@_%@.%@",video_array.firstObject,codec,[self currentDateString],video_array.lastObject]];
    }

    NSString *command_str_origin = [NSString stringWithFormat:@"ffmpeg -i %@",fromFile];
    //编码器选择
    if([codec isEqualToString:@"h264HW"]){
        command_str_origin = [command_str_origin stringByAppendingString:@" -c:a aac -c:v h264_videotoolbox"];
    }
    if([codec isEqualToString:@"x264"]){
        command_str_origin = [command_str_origin stringByAppendingString:@" -c:a aac -c:v libx264"];
    }
    if ([codec isEqualToString:@"h265HW"]) {
        command_str_origin = [command_str_origin stringByAppendingString:@" -c:a aac -c:v hevc_videotoolbox"];
    }
    
    //如果分辨率不为空
    if (self.chooseResolution != nil || self.chooseResolution.length != 0) {
        command_str_origin = [command_str_origin stringByAppendingFormat:@" -vf scale=%@",self.chooseResolution];
    }
    //如果帧率不为空
    if (self.chooseFps != nil || self.chooseFps.length != 0) {
        command_str_origin = [command_str_origin stringByAppendingFormat:@" -r %@",self.chooseFps];
    }
    
    if([br isEqualToString:@"abr"] && br != nil && br.length != 0){
        command_str_origin = [command_str_origin stringByAppendingFormat:@" -b:v %@k",coderate];
    }
    if ([br isEqualToString:@"cbr"] == YES && br != nil && coderate.length != 0) {
        command_str_origin = [command_str_origin stringByAppendingFormat:@" -b:v %@k -maxrate %@k -minrate %@k",coderate,coderate,coderate];
    }
    //GOP选择
    if([gop isEqualToString:@"gop_2fps"] && gop != nil && gop.length !=0){
        if (self.chooseFps != nil && self.chooseFps.length != 0) {
            command_str_origin = [command_str_origin stringByAppendingFormat:@" -g %d",self.chooseFps.intValue * 2];
        }
    }
    if([gop isEqualToString:@"gop_4fps"] && gop != nil && gop.length !=0){
        if (self.chooseFps != nil && self.chooseFps.length != 0) {
            command_str_origin = [command_str_origin stringByAppendingFormat:@" -g %d",self.chooseFps.intValue * 4];
        }
    }
    NSString *command_str = [NSString stringWithFormat:@"%@ %@ -y",command_str_origin,toFile];
    
    NSLog(@"最终的命令行参数:%@",command_str);
    return command_str.mutableCopy;
}
static int processCount = 0;
-(void)ffmpegCommandLine:(NSString *)command_str
{
    NSLog(@"------执行的命令行参数-------%@",command_str);
    // 分割字符串
    NSMutableArray  *argv_array  = [command_str componentsSeparatedByString:(@" ")].mutableCopy;
    // 获取参数个数
    int argc = (int)argv_array.count;
    // 遍历拼接参数
    char **argv = calloc(argc, sizeof(char*));
    for(int i=0; i<argc; i++)
    {
        NSString *codeStr = argv_array[i];
        argv_array[i]     = codeStr;
        argv[i]      = (char *)[codeStr UTF8String];
    }
    int result = ffmpeg_main(argc, argv);
    if (result == 0) {
        NSLog(@"生成成功第%d个",processCount++);
        //转码完成视频保存到相册
        [self saveVideoToAlbum:argv_array[argc - 2]];
        if (self.commandLineArray.count > 0) {
            [self.commandLineArray removeObjectAtIndex:0];
        }
        if (self.commandLineArray.count > 0) {
            [self ffmpegCommandLine:self.commandLineArray.firstObject];
        }
        else if (self.commandLineArray.count == 0) {
            processCount = 0;
            self.endTime = [self currentDateInterval];
            dispatch_async(dispatch_get_main_queue(), ^{
                ResultViewController *resultVC = [[ResultViewController alloc] init];
                resultVC.title = [NSString stringWithFormat:@"耗时:%lds",(self.endTime - self.startTime)/1000];
                [self.navigationController pushViewController:resultVC animated:YES];
            });
        }
    }else{
        NSLog(@"生成失败");
    }
}
-(void)saveVideoToAlbum:(NSString *)videoPath{
    if (videoPath) {
            NSURL *url = [NSURL URLWithString:videoPath];
            BOOL compatible = UIVideoAtPathIsCompatibleWithSavedPhotosAlbum([url path]);
            if (compatible)
            {
                //保存相册核心代码
                UISaveVideoAtPathToSavedPhotosAlbum([url path], self, @selector(savedPhotoImage:didFinishSavingWithError:contextInfo:), nil);
            }
        }
}
//保存视频完成之后的回调
- (void)savedPhotoImage:(UIImage*)image didFinishSavingWithError: (NSError *)error contextInfo: (void *)contextInfo {
    if (error) {
        NSLog(@"保存视频失败%@", error.localizedDescription);
    }
    else {
        NSLog(@"保存视频成功");
    }
}
-(void)getResources{
    //1获取bundle目录文件路径
        NSString *bundleDir = [[NSBundle mainBundle] bundlePath];
        NSLog(@"bundleDir   %@", bundleDir);  //   文件路径名
    //2获取目录下的所有文件名
     NSFileManager *fm = [NSFileManager defaultManager];
        NSArray *files = [fm subpathsAtPath:bundleDir];
        NSLog(@"files   %@", files);
    //创建一个可变数组，接收取出的文件名
    self.pathArray = [NSMutableArray array];
    self.nameArray = [NSMutableArray array];
    //3开始判断，获取 图片
    for (NSString *imageName in files) {
        //判断字符串 是否以 “.mp4结尾”
        if ([imageName hasSuffix:@".mp4"]) {
            NSString *path = [[[NSBundle mainBundle] bundlePath]stringByAppendingPathComponent:imageName];
            [self.pathArray addObject:path];
            [self.nameArray addObject:imageName];
        }
        if ([imageName hasSuffix:@".MOV"]) {
            NSString *path = [[[NSBundle mainBundle] bundlePath]stringByAppendingPathComponent:imageName];
            [self.pathArray addObject:path];
            [self.nameArray addObject:imageName];
        }
    }
    // 结果
    NSLog(@"pathArray content are %@", self.pathArray);
    NSLog(@"nameArray content are %@", self.nameArray);
#warning ...add
#warning ...增加一个相册访问
    [self.pathArray addObject:@"相册"];
    [self.nameArray addObject:@"相册"];
}
-(void)ffmpegMp4libx264{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *fromFile = [[NSBundle mainBundle]pathForResource:@"movie" ofType:@"mp4"];
        NSString *imageName = @"image000.mp4";
        NSString *imagesPath = [NSString stringWithFormat:@"%@/%@", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject], imageName];
        
        int argc = 9;
        char **arguments = calloc(argc, sizeof(char*));
        if(arguments != NULL)
        {
            arguments[0] = "ffmpeg";
            arguments[1] = "-i";
            arguments[2] = (char *)[fromFile UTF8String];
            arguments[3] = "-c:a";
            arguments[4] = "aac";
            arguments[5] = "-c:v";
            arguments[6] = "libx264";
            arguments[7] = (char *)[imagesPath UTF8String];
            arguments[8] = "-y";
            int result = ffmpeg_main(argc, arguments);
            if (result != 0) {
                NSLog(@"生成成功");
                dispatch_async(dispatch_get_main_queue(), ^{
                    ResultViewController *resultVC = [[ResultViewController alloc] init];
                    [self.navigationController pushViewController:resultVC animated:YES];
                });
            }else{
                NSLog(@"生成失败");
            }
        }
    });
}
-(void)ffmpegMp4VideoToolBox{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *fromFile = [[NSBundle mainBundle]pathForResource:@"movie" ofType:@"mp4"];
        NSString *imageName = @"image000.mp4";
        NSString *imagesPath = [NSString stringWithFormat:@"%@/%@", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject], imageName];
        
        int argc = 9;
        char **arguments = calloc(argc, sizeof(char*));
        if(arguments != NULL)
        {
            arguments[0] = "ffmpeg";
            arguments[1] = "-i";
            arguments[2] = (char *)[fromFile UTF8String];
            arguments[3] = "-c:a";
            arguments[4] = "aac";
            arguments[5] = "-c:v";
            arguments[6] = "h264_videotoolbox";
            arguments[7] = (char *)[imagesPath UTF8String];
            arguments[8] = "-y";
            int result = ffmpeg_main(argc, arguments);
            if (result != 0) {
                NSLog(@"生成成功");
                dispatch_async(dispatch_get_main_queue(), ^{
                    ResultViewController *resultVC = [[ResultViewController alloc] init];
                    [self.navigationController pushViewController:resultVC animated:YES];
                });
            }else{
                NSLog(@"生成失败");
            }
        }
    });
}
-(void)ffmpegtest{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //ffmpeg -i video.mov -f gif 1.gif
        //ffmpeg -ss 25 -t 10 -i D:\Media\bear.wmv -f gif D:\a.gif
        //ffmpeg -ss 0 -t 3 -i video.mov -pix_fmt rgb24 -f gif 11.gif
        NSString *fromFile = [[NSBundle mainBundle]pathForResource:@"video" ofType:@"mov"];
//        NSString *toFile = @"/Users/cloud/Desktop/video.gif";
//        NSString *imageName = @"image.gif";
        NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
        NSString *toFile0 = [documentPath stringByAppendingPathComponent:@"image.gif"];
//        NSString *toFile = [NSString stringWithFormat:@"%@/%@", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject], imageName];
        int argc = 14;
        char **arguments = calloc(argc, sizeof(char*));
        if(arguments != NULL)
        {
            arguments[0] = "ffmpeg";
            arguments[1] = "-ss";
            arguments[2] = "0";
            arguments[3] = "-t";
            arguments[4] = "3";
            arguments[5] = "-i";
            arguments[6] = (char *)[fromFile UTF8String];
            arguments[7] = "-pix_fmt";
            arguments[8] = "rgb24";
            arguments[9] = "-f";
            arguments[10] = "gif";
            arguments[11] = "-r";
            arguments[12] = "1";
            arguments[13] = (char *)[toFile0 UTF8String];
             
            int result = ffmpeg_main(argc, arguments);
            if (result != 0) {
                NSLog(@"生成成功");
                dispatch_async(dispatch_get_main_queue(), ^{
                    ResultViewController *resultVC = [[ResultViewController alloc] init];
                    [self.navigationController pushViewController:resultVC animated:YES];
                });
            }else{
                NSLog(@"生成失败");
            }
        }
    });
}
-(void)ffmpegtestOne{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *fromFile = [[NSBundle mainBundle]pathForResource:@"MyHeartWillGoOn" ofType:@"mp4"];
        NSString *imageName = @"image%d.jpg";
        NSString *imagesPath = [NSString stringWithFormat:@"%@/%@", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject], imageName];
        
        int argc = 6;
        char **arguments = calloc(argc, sizeof(char*));
        if(arguments != NULL)
        {
            arguments[0] = "ffmpeg";
            arguments[1] = "-i";
            arguments[2] = (char *)[fromFile UTF8String];
            arguments[3] = "-r";
            arguments[4] = "20";
            arguments[5] = (char *)[imagesPath UTF8String];
            int result = ffmpeg_main(argc, arguments);
            if (result != 0) {
                NSLog(@"生成成功");
                dispatch_async(dispatch_get_main_queue(), ^{
                    ResultViewController *resultVC = [[ResultViewController alloc] init];
                    [self.navigationController pushViewController:resultVC animated:YES];
                });
            }else{
                NSLog(@"生成失败");
            }
        }
    });
}
-(void)ffmpegtestMovToMp4Two{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //ffmpeg -i video.mov -q 1 -c copy ttt.mp4
        NSString *fromFile = [[NSBundle mainBundle]pathForResource:@"video.mov" ofType:nil];
        NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
        NSString *toFile = [documentPath stringByAppendingPathComponent:@"ttt.mp4"];
        int argc = 8;
        char **arguments = calloc(argc, sizeof(char*));
        if(arguments != NULL)
        {
            arguments[0] = "ffmpeg";
            arguments[1] = "-i";
            arguments[2] = (char *)[fromFile UTF8String];
            arguments[3] = "-q";
            arguments[4] = "1";
            arguments[5] = "-c";
            arguments[6] = "copy";
            arguments[7] = (char *)[toFile UTF8String];
            if (!ffmpeg_main(argc, arguments)) {
                NSLog(@"生成成功");
            }else{
                NSLog(@"生成失败");
            }
        }
    });
}
@end
