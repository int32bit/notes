# ubuntu终端显示中文乱码

## Problem

终端突然无法输入中文，并且无法显示中文，中文显示为*？？？*。切换其他用户，可以正常工作，并且nautilus中文显示正常.

## Solution
可以排除是编码设置问题，因为其他应用都显示正常。于是问题一定在于软件配置。由于使用的是gnome-terminal，
因此可能是这个app的问题。尝试修改profile preferences无果。尝试gconf，该app的配置在~/.gconf/apps/gnome-terminal下，
为了还原默认设置，只需要删除gnome-terminal这个目录即可，恢复正常。
