/*
 
 Copyright (c) 2013, Tyler Zetterstrom
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR ANY
 DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 */

//
//  OLKHandsContainerViewController.h
//  OpenLeapKit
//
//  Created by Tyler Zetterstrom on 2013-08-22.
//

#import <Foundation/Foundation.h>
#import "OLKSimpleVectHandView.h"

@protocol OLKHandsContainerViewControllerDataSource <NSObject>

- (NSView <OLKHandContainer>*)handView:(NSRect)frame withHandedness:(OLKHandedness)handedness;

@end

@protocol OLKHandsContainerViewControllerDelegate <NSObject>

- (void)hand:(NSRect)frame withHandedness:(OLKHandedness)handedness;

@end

@interface OLKHandsContainerViewController : NSObject

- (void)onFrame:(NSNotification *)notification;

@property (nonatomic) NSView *handsContainerView;
@property (nonatomic) NSObject <OLKHandsContainerViewControllerDataSource> *dataSource;
@property (nonatomic, readonly) OLKHand *leftHand;
@property (nonatomic, readonly) OLKHand *rightHand;
@property (nonatomic, readonly) NSView <OLKHandContainer> *leftHandView;
@property (nonatomic, readonly) NSView <OLKHandContainer> *rightHandView;

@end
