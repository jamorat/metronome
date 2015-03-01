//  ViewController.m
//  Variable Metrognome / Asymetric Rhythm
//
/*
Created by Brian Sleeper and Jack Amoratis on 5/17/14.
We think this is awesome source code, but in all humility, there's nothing proprietary going on here. An NSTimer, some sounds being played, some decimals being converted into fractions. That pretty much represents the functionality of this asymmetric rhythm tool. All you need to do is wire this code to a UITableView along with some buttons, a slider, and a few labels, and you will have your own working asymetric rhythm app. If you want to make use of this code, then feel free to fork it, or just cut and paste it into your project.
 - Jack Amoratis and Brian Sleeper
 
 
 ## License
 To the extent possible under law, we (Brian Sleeper and Jack Amoratis) have waived all copyright and related or neighboring rights to this source code. This work is published from: United States. No warranty is expressed or implied, nor is any fitness for a particular purpose implied. Use at your own risk.
 */

#import "MetronomeAppDelegate.h"
#import "MetronomeViewController.h"
# undef M_PI_2
# define M_PI_2     1.57079632679489661923

@interface MetronomeViewController ()
@property (nonatomic, retain) IBOutlet UITableView *timingList;
@property (nonatomic, assign) int counter;
@property float currentItemMSTop;
@property float quarterNoteMS;
@property float eighthNoteMS;
@property float halfNoteMS;
@property float dottedHalfNoteMS;
@property (nonatomic, assign) int itemCounter;
@property (nonatomic, assign) int whichSound;
@property (nonatomic) NSMutableArray *noteIcons;
@end

@implementation MetronomeViewController

MetronomeAppDelegate *metronomeAppDelegate;
-(void)viewDidDisappear:(BOOL)animated{
    [self startStopTimer:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _plusButton.titleLabel.font = [UIFont systemFontOfSize:20];
    _timeItems = [NSMutableArray arrayWithObjects: @1, @1, @2, nil];
    _noteIcons = [NSMutableArray arrayWithObjects:@"eighth-note.png",@"quarter-note.png",@"half-note.png",@"dotted-half-note.png",nil];
    [_timingList reloadData];
    self.stepValue = 1.0f;
    [self.editButton setTitle:@"Edit" forState:UIControlStateNormal];
    self.bpmSlideController.value = 320;
    [self updateSlider];
}

- (NSUInteger)supportedInterfaceOrientations {
    return  UIInterfaceOrientationMaskAll;
}

-(BOOL)shouldAutorotate{
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return TRUE;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [self startStopTimer:NO];
    NSLog(@"%@",@"Show alert low memory");
}

- (IBAction)pushedGoButton:(id)sender {
    [self startStopTimer:NO];
}

- (void) startStopTimer:(BOOL)specialStopFlag{
    
    if ([[_goButton currentTitle] isEqualToString:@"Start"] && specialStopFlag != YES) {
        [_goButton setTitle:@"Stop" forState:UIControlStateNormal];
        [_goButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        NSLog(@"Started");
        NSURL *soundURL1 = [[NSBundle mainBundle] URLForResource:@"tone" withExtension:@"aiff"];        AudioServicesCreateSystemSoundID(CFBridgingRetain(soundURL1), &sound2);
        [self metroAct];
        
    }else{
        NSLog(@"Stopped");
        [_goButton setTitle:@"Start" forState:UIControlStateNormal];
        [_goButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
        [_bpmTimer invalidate];
        _bpmTimer = nil;
    }
}

- (void)metroAct
{
    if ([_timeItems count] < 1) {
        [self startStopTimer:YES];
    }
    
    //will crash if stop while last item on the list is highlighted
    //at that point the counter is above the count of time items - 1
    if (_counter > [_timeItems count]-1){
        _counter = 0;
    }
    
    _whichSound = [[_timeItems objectAtIndex:_counter] intValue];
    NSLog(@"whichSound: %i", _whichSound);
    [_timingList scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_counter inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
    //CURRENT CELL NOTE VALUE
    if (_whichSound == 0){
        _currentItemMSTop = 60/_eighthNoteMS;
    }else if(_whichSound == 1){
        _currentItemMSTop = 60/_quarterNoteMS;
    }else if(_whichSound == 2){
        _currentItemMSTop = 60/_halfNoteMS;
    }else if(_whichSound == 3){
        _currentItemMSTop = 60/_dottedHalfNoteMS;
    }
    _bpmTimer = [NSTimer scheduledTimerWithTimeInterval:(_currentItemMSTop) target:self selector:@selector(soundPlayMethod) userInfo:nil repeats:NO];
}

- (void)soundPlayMethod{
    AudioServicesPlaySystemSound(sound2);
    if (_counter > ([_timeItems count]-1)){
        _counter = 0;
    }
    [_timingList reloadData];
    [self metroAct];
    _counter++;
}

- (IBAction)bpmSlideControllerAction:(UISlider *)sender {
    [self updateSlider];
}

-(void)updateSlider{
    float newStep = roundf((self.bpmSlideController.value) / self.stepValue);
    
    self.bpmSlideController.value = newStep * self.stepValue;
    
    _eighthNoteMS = (float)self.bpmSlideController.value;
    _quarterNoteMS = (float)self.bpmSlideController.value/2;
    _halfNoteMS = (float)self.bpmSlideController.value/3;
    _dottedHalfNoteMS = (float)self.bpmSlideController.value/4;
    
    self.bpmDisplay.text = [self intFromFloat:_eighthNoteMS];
    self.quarterNote.text = [self intFromFloat:_quarterNoteMS];
    self.halfNote.text = [self intFromFloat:_halfNoteMS];
    self.dottedHalfNote.text = [self intFromFloat:_dottedHalfNoteMS];
}

- (NSString *)intFromFloat:(float)param{
    //first get main display number
    int roundedBPM = floor(param);
    
    //then get fraction ending, if any
    int whichFraction = 100 * (param-floor(param));
    if (whichFraction == 0){
        return [NSString stringWithFormat:@"%d",roundedBPM ];
    } else if(whichFraction == 25) {
        return [NSString stringWithFormat:@"%d ¼",roundedBPM];
    } else if (whichFraction == 33) {
        return [NSString stringWithFormat:@"%d ⅓",roundedBPM];
    } else if (whichFraction == 50) {
        return [NSString stringWithFormat:@"%d ½",roundedBPM];
    } else if (whichFraction == 66) {
        return [NSString stringWithFormat:@"%d ⅔",roundedBPM];
    } else {
        return @"";
    }
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.timeItems.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString * ident = @"aCell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:nil];
    if (cell ==nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ident];
        int txt = [[self.timeItems objectAtIndex:indexPath.row] intValue];
        NSLog(@"Current txt: %i row: %li",txt, (long)indexPath.row);
        
        if (txt == 0) {
            cell.textLabel.font =[UIFont fontWithName:@"MusiSync" size:70];
            cell.textLabel.text = @"  e";
        }else if (txt == 1) {
            cell.textLabel.font =[UIFont fontWithName:@"MusiSync" size:70];
            cell.textLabel.text = @"  q";
        }else if (txt == 2) {
            cell.textLabel.font =[UIFont fontWithName:@"MusiSync" size:70];
            cell.textLabel.text = @"  j";
        }else if (txt == 3) {
            cell.textLabel.font =[UIFont fontWithName:@"MusiSync" size:70];
            cell.textLabel.text = @"  h";
        }
        
        if (indexPath.row == _counter-1){
            [cell setBackgroundColor:[UIColor orangeColor]];
            [cell setHighlighted:YES];
        }
        [[cell imageView] setHidden:NO];
    }
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //handles taps on the cells to change value
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([[_timeItems objectAtIndex:indexPath.row] isEqualToString:@"0"]) {
        [_timeItems replaceObjectAtIndex:indexPath.row withObject:[NSString stringWithFormat:@"1"]];
        cell.imageView.image = [UIImage imageNamed:_noteIcons[0]];
    } else if ([[_timeItems objectAtIndex:indexPath.row] isEqualToString:@"1"]) {
        [_timeItems replaceObjectAtIndex:indexPath.row withObject:[NSString stringWithFormat:@"2"]];
    } else if ([[_timeItems objectAtIndex:indexPath.row] isEqualToString:@"2"]) {
        [_timeItems replaceObjectAtIndex:indexPath.row withObject:[NSString stringWithFormat:@"3"]];
        cell.imageView.image = [UIImage imageNamed:_noteIcons[2]];
    } else if ([[_timeItems objectAtIndex:indexPath.row] isEqualToString:@"3"]) {
        [_timeItems replaceObjectAtIndex:indexPath.row withObject:[NSString stringWithFormat:@"0"]];
        cell.imageView.image = [UIImage imageNamed:_noteIcons[3]];
    }
    [_timingList reloadData];
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete){
        
        if (indexPath.row < [_timeItems count]){
            
            /* First remove this object from the source */
            [_timeItems removeObjectAtIndex:indexPath.row];
            
            /* Then remove the associated cell from the Table View */
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationLeft];
        }
    }
}

- (IBAction)addItem:(UIButton *)sender {
    [_timeItems addObject:@"1"];
    [_timingList reloadData];
    [_timingList scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[_timeItems count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    [_timingList flashScrollIndicators];
}

- (IBAction)editButtonPush:(id)sender {
    if ([[sender currentTitle] isEqualToString:@"Edit"]){
        [sender setTitle:@"Done" forState:UIControlStateNormal];
        _timingList.editing=YES;
    } else {
        [sender setTitle:@"Edit" forState:UIControlStateNormal];
        _timingList.editing=NO;
    }
}

- (IBAction)clearButtonPressed:(UIButton *)sender {
    _timeItems = [NSMutableArray arrayWithObjects: @"0", nil];
    [_timingList reloadData];
    [self startStopTimer:YES];
}
@end
