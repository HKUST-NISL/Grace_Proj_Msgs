#!/usr/bin/env bash
##
## Copyright (c) 2020 Hanson Robotics.
##
## This file is part of Hanson AI.
## See https://www.hansonrobotics.com/hanson-ai for further info.
##
## Licensed under the Apache License, Version 2.0 (the "License");
## you may not use this file except in compliance with the License.
## You may obtain a copy of the License at
##
##     http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.
##

package() {
    local reponame=Grace_Proj_Msgs
    local pkgname=grace_attn_msgs 

    mkdir -p $BASEDIR/src
    rsync -r --delete \
        --exclude ".git" \
        --exclude "package" \
        $BASEDIR/../ $BASEDIR/src/$reponame

    get_version $1
    source_ros
    catkin_make_isolated --directory $BASEDIR --install --install-space $BASEDIR/install -DCMAKE_BUILD_TYPE=Release

    local name
    local desc="ROS message definition for Grace Attention"
    local url="https://github.com/HKUST-NISL/Grace_Proj_Msgs/releases"

    local pythonpath
    local rosdistro=$(find_rosdistro)
    if [[ $rosdistro == noetic ]]; then
        pythonpath=install/lib/python3/
    else
        pythonpath=install/lib/python2.7/
    fi

    for dist in kinetic melodic ; do
        name=head-$dist-$pkgname
        ROS_PREFIX=/opt/ros/$dist

        #remove version & date
        #-p $BASEDIR/${name}_VERSION_ARCH.deb \ 
        fpm -C "${BASEDIR}" -s dir -t deb -n "${name}" -v "${version#v}" --vendor "${VENDOR}" \
            --url "${url}" --description "${desc}" ${ms} --force \
            --deb-no-default-config-files \
            -p $BASEDIR/${name}.deb \
            install/include=${ROS_PREFIX}/ \
            install/share=${ROS_PREFIX}/ \
            install/lib/pkgconfig/=${ROS_PREFIX}/lib/pkgconfig/ \
            $pythonpath=${ROS_PREFIX}/lib/python2.7/
    done

    for dist in noetic; do
        name=head-$dist-$pkgname
        ROS_PREFIX=/opt/ros/$dist

        #remove version & date
        #-p $BASEDIR/${name}_VERSION_ARCH.deb \
        fpm -C "${BASEDIR}" -s dir -t deb -n "${name}" -v "${version#v}" --vendor "${VENDOR}" \
            --url "${url}" --description "${desc}" ${ms} --force \
            --deb-no-default-config-files \
            -p $BASEDIR/${name}.deb \
            install/include=${ROS_PREFIX}/ \
            install/share=${ROS_PREFIX}/ \
            install/lib/pkgconfig/=${ROS_PREFIX}/lib/pkgconfig/ \
            $pythonpath=${ROS_PREFIX}/lib/python3/
    done

    cleanup_ros_package_build $BASEDIR
}

if [[ $(readlink -f ${BASH_SOURCE[0]}) == $(readlink -f $0) ]]; then
    BASEDIR=$(dirname $(readlink -f ${BASH_SOURCE[0]}))
    source $BASEDIR/common.sh
    set -e

    package $1
fi