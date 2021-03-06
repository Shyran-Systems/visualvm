#!/bin/sh

# DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS HEADER.
#
# Copyright 2020 Oracle and/or its affiliates. All rights reserved.
#
# Oracle and Java are registered trademarks of Oracle and/or its affiliates.
# Other names may be trademarks of their respective owners.
#
# The contents of this file are subject to the terms of either the GNU
# General Public License Version 2 only ("GPL") or the Common
# Development and Distribution License("CDDL") (collectively, the
# "License"). You may not use this file except in compliance with the
# License. You can obtain a copy of the License at
# http://www.netbeans.org/cddl-gplv2.html
# or nbbuild/licenses/CDDL-GPL-2-CP. See the License for the
# specific language governing permissions and limitations under the
# License.  When distributing the software, include this License Header
# Notice in each file and include the License file at
# nbbuild/licenses/CDDL-GPL-2-CP.  Oracle designates this
# particular file as subject to the "Classpath" exception as provided
# by Oracle in the GPL Version 2 section of the License file that
# accompanied this code. If applicable, add the following below the
# License Header, with the fields enclosed by brackets [] replaced by
# your own identifying information:
# "Portions Copyrighted [year] [name of copyright owner]"
#
# Contributor(s):
#
# The Original Software is NetBeans. The Initial Developer of the Original
# Software is Sun Microsystems, Inc. Portions Copyright 1997-2006 Sun
# Microsystems, Inc. All Rights Reserved.
#
# If you wish your version of this file to be governed by only the CDDL
# or only the GPL Version 2, indicate your decision by adding
# "[Contributor] elects to include this software in this distribution
# under the [CDDL or GPL Version 2] license." If you do not indicate a
# single choice of license, a recipient has the option to distribute
# your version of this file under either the CDDL, the GPL Version 2 or
# to extend the choice of license to its licensees as provided above.
# However, if you add GPL Version 2 code and therefore, elected the GPL
# Version 2 license, then the option applies only if the new code is
# made subject to such option by the copyright holder.

BuildForJDK()
{
	SYSROOT=$1
	JDK_ID=$2
	JDK_VER=$3
	echo $SYSROOT $JDK_ID $JAVA_HOME

	CC_OPTS="-c -I$JAVA_HOME/include -I$JAVA_HOME/include/darwin \
        -pipe -Wno-trigraphs -fpascal-strings -fasm-blocks \
	-Os -Wunused-variable -fmessage-length=0 -mmacosx-version-min=11.0 -Wmost \
	-Wno-four-char-constants -Wno-unknown-pragmas -isysroot $SYSROOT -DLINUX"

	LD_OPTS="-Wl,-single_module -compatibility_version 1 -current_version 1 \
	-dynamiclib -mmacosx-version-min=11.0 -isysroot $SYSROOT"

	SOURCES="../src-jdk15/class_file_cache.c \
	../src-jdk15/attach.c \
	../src-jdk15/Classes.c \
	../src-jdk15/HeapDump.c \
	../src-jdk15/Timers.c \
	../src-jdk15/GC.c \
	../src-jdk15/Threads.c \
	../src-jdk15/Stacks.c \
	../src-jdk15/common_functions.c"

	OBJ_FILES="class_file_cache.o \
	attach.o \
	Classes.o \
	HeapDump.o \
	Timers.o \
	GC.o \
	Threads.o \
	Stacks.o \
	common_functions.o"

	BuildForArch "arm64"

        cp ../../release/lib/deployed/$JDK_ID/mac/libprofilerinterface.jnilib .
	lipo libprofilerinterface.jnilib -replace arm64 libprofilerinterface_arm64.jnilib \
	-output ../../release/lib/deployed/$JDK_ID/mac/libprofilerinterface.jnilib

	rm *.jnilib

}

BuildForArch()
{
        ARCH=$1
        echo "ARCH "$ARCH

        clang $CC_OPTS -arch $ARCH $SOURCES
        clang $LD_OPTS -arch $ARCH -o libprofilerinterface_$ARCH.jnilib $OBJ_FILES

        rm *.o
}

BuildForJDK "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX11.0.sdk" "jdk16" "1.6"

