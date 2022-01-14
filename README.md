# Adaptive Modular Reinforcement Learning for Robot Controlled in Multiple Environments

This repository contains the source code used in the experiments in the paper.
Written in poor English, please contact the co-author if you have any questions.

## Requirement 

Following toolboxes are required to use this library itself.
* MATLAB2020a (v9.8)
* Reinforcement learning toolbox v1.2
* Deep Learning Toolbox v14.0

Following toolboxes are requied to run sample scripts for creating environment.
* Simulink v10.1
* Control System Toolbox  v10.8

## Folder structure

* experiment1~3: Each experiment in the treatise is stored in the corresponding folder.
* libs: A self-made library for operating the experimental code normally is included.
* install.m: This file is used to add the path of self-made library in MATLAB.
* README.md: This file.

## How to use

1. Before executing each experimental code, pass the path of your own library.
   Run ```install.m``` to add path.
2. Run the experimental code.
