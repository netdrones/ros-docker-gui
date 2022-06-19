# If the first argument is ...
ifneq (,$(findstring tools_,$(firstword $(MAKECMDGOALS))))
	# use the rest as arguments
	RUN_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
	# ...and turn them into do-nothing targets
	#$(eval $(RUN_ARGS):;@:)
endif

# make it easy to switch to a new repo
ORG ?= turlucode

.PHONY: help
help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[0-9a-zA-Z_-]+:.*?## / {printf "\033[36m%-42s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
.DEFAULT_GOAL := help

# patsubst search for arg1 and for every word in arg3 replaces it with arg2
# to get the all to work we need to parse the file looking for all phony
# targets
# https://stackoverflow.com/questions/4219255/how-do-you-get-the-list-of-targets-in-a-makefile
# need this hack for includes and must be before any includes
THIS_FILE ?= $(lastword $(MAKEFILE_LIST))
BUILD_LIST ?= $(shell grep -o -E '^[a-zA-Z0-9_-]+:' $(THIS_FILE) | \
						sed -e 's/:$$//' | \
						grep -E '^nvidia|cpu|tools' \
			   )
.PHONY: $(BUILD_LIST)
# note we are only looking for targets that start with nvidia_, cpu_ and tools_
# this calls make so cannot do recursively
.PHONY: test-list
test-list:
	@grep -o -E '^[a-zA-Z0-9_-]+:' $(THIS_FILE) | \
			sed -e 's/:$$//' | \
			grep -E '^nvidia|cpu|tools'
# this cannot be used recursively as it calls make to produce the list
.PHONY: make-list
make-list:
	@$(MAKE) -pRrq -f $(lastword $(THIS_FILE)) : 2>/dev/null | \
		awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | \
		sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$' | \
		grep -E '^nvidia_|cpu_|tools_'

# build all container
.PHONY: all
all: $(BUILD_LIST)

# DOCKER TASKS

# NVIDIA
## INDIGO

nvidia_ros_indigo: ## [NVIDIA] Build ROS  Indigo  Container
	docker build -t $(ORG)/ros-indigo:nvidia -f nvidia/indigo/base/Dockerfile .
	@printf "\n\033[92mDocker Image: $(ORG)/ros-indigo:nvidia\033[0m\n"

nvidia_ros_indigo_opencv3: nvidia_ros_indigo ## [NVIDIA] Build ROS  Indigo  Container | (----------------------) | OpenCV 3.4.7
	docker build -t $(ORG)/ros-indigo:opencv3 -f nvidia/indigo/opencv3/Dockerfile .
	@printf "\n\033[92mDocker Image: $(ORG)/ros-indigo:opencv3\033[0m\n"

nvidia_ros_indigo_cuda8: nvidia_ros_indigo ## [NVIDIA] Build ROS  Indigo  Container | (CUDA  8     - no cuDNN)
	docker build -t $(ORG)/ros-indigo:cuda8 -f nvidia/indigo/cuda8/Dockerfile .
	@printf "\n\033[92mDocker Image: $(ORG)/ros-indigo:cuda8\033[0m\n"

nvidia_ros_indigo_cuda10: nvidia_ros_indigo ## [NVIDIA] Build ROS  Indigo  Container | (CUDA 10     - no cuDNN)
	docker build -t $(ORG)/ros-indigo:cuda10 -f nvidia/indigo/cuda10/Dockerfile .
	@printf "\n\033[92mDocker Image: $(ORG)/ros-indigo:cuda10\033[0m\n"

nvidia_ros_indigo_cuda10-1: nvidia_ros_indigo ## [NVIDIA] Build ROS  Indigo  Container | (CUDA 10.1   - no cuDNN)
	docker build -t $(ORG)/ros-indigo:cuda10.1 -f nvidia/indigo/cuda10.1/Dockerfile .
	@printf "\n\033[92mDocker Image: $(ORG)/ros-indigo:cuda10.1\033[0m\n"

nvidia_ros_indigo_cuda8_cudnn6: nvidia_ros_indigo_cuda8 ## [NVIDIA] Build ROS  Indigo  Container | (CUDA  8     - cuDNN 6)
	docker build -t $(ORG)/ros-indigo:cuda8-cudnn6 -f nvidia/indigo/cuda8/cudnn6/Dockerfile .
	@printf "\n\033[92mDocker Image: $(ORG)/ros-indigo:cuda8-cudnn6\033[0m\n"

nvidia_ros_indigo_cuda8_cudnn7: nvidia_ros_indigo_cuda8 ## [NVIDIA] Build ROS  Indigo  Container | (CUDA  8     - cuDNN 7)
	docker build -t $(ORG)/ros-indigo:cuda8-cudnn7 -f nvidia/indigo/cuda8/cudnn7/Dockerfile .
	@printf "\n\033[92mDocker Image: $(ORG)/ros-indigo:cuda8-cudnn7\033[0m\n"

nvidia_ros_indigo_cuda10_cudnn7: nvidia_ros_indigo_cuda10 ## [NVIDIA] Build ROS  Indigo  Container | (CUDA 10     - cuDNN 7)
	docker build -t $(ORG)/ros-indigo:cuda10-cudnn7 -f nvidia/indigo/cuda10/cudnn7/Dockerfile .
	@printf "\n\033[92mDocker Image: $(ORG)/ros-indigo:cuda10-cudnn7\033[0m\n"

nvidia_ros_indigo_cuda10-1_cudnn7: nvidia_ros_indigo_cuda10-1 ## [NVIDIA] Build ROS  Indigo  Container | (CUDA 10.1   - cuDNN 7)
	docker build -t $(ORG)/ros-indigo:cuda10.1-cudnn7 -f nvidia/indigo/cuda10.1/cudnn7/Dockerfile .
	@printf "\n\033[92mDocker Image: $(ORG)/ros-indigo:cuda10.1-cudnn7\033[0m\n"

nvidia_ros_indigo_cuda8_opencv3: nvidia_ros_indigo_cuda8 ## [NVIDIA] Build ROS  Indigo  Container | (CUDA  8     - no cuDNN) | OpenCV 3.4.7
	docker build -t $(ORG)/ros-indigo:cuda8-opencv3 -f nvidia/indigo/cuda8/opencv3/Dockerfile .
	@printf "\n\033[92mDocker Image: $(ORG)/ros-indigo:cuda8-opencv3\033[0m\n"

nvidia_ros_indigo_cuda10_opencv3: nvidia_ros_indigo_cuda10 ## [NVIDIA] Build ROS  Indigo  Container | (CUDA 10     - no cuDNN) | OpenCV 3.4.7
	docker build -t $(ORG)/ros-indigo:cuda10-opencv3 -f nvidia/indigo/cuda10/opencv3/Dockerfile .
	@printf "\n\033[92mDocker Image: $(ORG)/ros-indigo:cuda10-opencv3\033[0m\n"

nvidia_ros_indigo_cuda8_cudnn6_opencv3: nvidia_ros_indigo_cuda8_cudnn6 ## [NVIDIA] Build ROS  Indigo  Container | (CUDA  8     - cuDNN 6)  | OpenCV 3.4.7
	docker build -t $(ORG)/ros-indigo:cuda8-cudnn6-opencv3 -f nvidia/indigo/cuda8/cudnn6/opencv3/Dockerfile .
	@printf "\n\033[92mDocker Image: $(ORG)/ros-indigo:cuda8-cudnn6-opencv3\033[0m\n"

nvidia_ros_indigo_cuda8_cudnn7_opencv3: nvidia_ros_indigo_cuda8_cudnn7 ## [NVIDIA] Build ROS  Indigo  Container | (CUDA  8     - cuDNN 7)  | OpenCV 3.4.7
	docker build -t $(ORG)/ros-indigo:cuda8-cudnn7-opencv3 -f nvidia/indigo/cuda8/cudnn7/opencv3/Dockerfile .
	@printf "\n\033[92mDocker Image: $(ORG)/ros-indigo:cuda8-cudnn7-opencv3\033[0m\n"

nvidia_ros_indigo_cuda10_cudnn7_opencv3: nvidia_ros_indigo_cuda10_cudnn7 ## [NVIDIA] Build ROS  Indigo  Container | (CUDA 10     - cuDNN 7)  | OpenCV 3.4.7
	docker build -t $(ORG)/ros-indigo:cuda10-cudnn7-opencv3 -f nvidia/indigo/cuda10/cudnn7/opencv3/Dockerfile .
	@printf "\n\033[92mDocker Image: $(ORG)/ros-indigo:cuda10-cudnn7-opencv3\033[0m\n"

nvidia_ros_indigo_cuda10-1_cudnn7_opencv3: nvidia_ros_indigo_cuda10-1_cudnn7 ## [NVIDIA] Build ROS  Indigo  Container | (CUDA 10.1   - cuDNN 7)  | OpenCV 3.4.7
	docker build -t $(ORG)/ros-indigo:cuda10.1-cudnn7-opencv3 -f nvidia/indigo/cuda10.1/cudnn7/opencv3/Dockerfile .
	@printf "\n\033[92mDocker Image: $(ORG)/ros-indigo:cuda10.1-cudnn7-opencv3\033[0m\n"

## KINETIC

nvidia_ros_kinetic: ## [NVIDIA] Build ROS  Kinetic Container
	docker build -t $(ORG)/ros-kinetic:nvidia -f nvidia/kinetic/base/Dockerfile .
	@printf "\n\033[92mDocker Image: $(ORG)/ros-kinetic:nvidia\033[0m\n"

nvidia_ros_kinetic_opencv3: nvidia_ros_kinetic ## [NVIDIA] Build ROS  Kinetic Container | (----------------------) | OpenCV 3.4.17
	docker build -t $(ORG)/ros-kinetic:opencv3 -f nvidia/kinetic/opencv3/Dockerfile .
	@printf "\n\033[92mDocker Image: $(ORG)/ros-kinetic:opencv3\033[0m\n"

nvidia_ros_kinetic_cuda8: nvidia_ros_kinetic ## [NVIDIA] Build ROS  Kinetic Container | (CUDA  8     - no cuDNN)
	docker build -t $(ORG)/ros-kinetic:cuda8 -f nvidia/kinetic/cuda8/Dockerfile .
	@printf "\n\033[92mDocker Image: $(ORG)/ros-kinetic:cuda8\033[0m\n"

nvidia_ros_kinetic_cuda10: nvidia_ros_kinetic ## [NVIDIA] Build ROS  Kinetic Container | (CUDA 10     - no cuDNN)
	docker build -t $(ORG)/ros-kinetic:cuda10 -f nvidia/kinetic/cuda10/Dockerfile .
	@printf "\n\033[92mDocker Image: $(ORG)/ros-kinetic:cuda10\033[0m\n"

nvidia_ros_kinetic_cuda8_cudnn6: nvidia_ros_kinetic_cuda8 ## [NVIDIA] Build ROS  Kinetic Container | (CUDA  8     - cuDNN 6)
	docker build -t $(ORG)/ros-kinetic:cuda8-cudnn6 -f nvidia/kinetic/cuda8/cudnn6/Dockerfile .
	@printf "\n\033[92mDocker Image: $(ORG)/ros-kinetic:cuda8-cudnn6\033[0m\n"

nvidia_ros_kinetic_cuda10_cudnn7: nvidia_ros_kinetic_cuda10 ## [NVIDIA] Build ROS  Kinetic Container | (CUDA 10     - cuDNN 7)
	docker build -t $(ORG)/ros-kinetic:cuda10-cudnn7 -f nvidia/kinetic/cuda10/cudnn7/Dockerfile .
	@printf "\n\033[92mDocker Image: $(ORG)/ros-kinetic:cuda10-cudnn7\033[0m\n"

nvidia_ros_kinetic_cuda8_opencv3: nvidia_ros_kinetic_cuda8 ## [NVIDIA] Build ROS  Kinetic Container | (CUDA  8     - no cuDNN) | OpenCV 3.4.17
	docker build -t $(ORG)/ros-kinetic:cuda8-opencv3 -f nvidia/kinetic/opencv3/Dockerfile .
	@printf "\n\033[92mDocker Image: $(ORG)/ros-kinetic:cuda8-opencv3_latest\033[0m\n"

nvidia_ros_kinetic_cuda8_cudnn6_opencv3: nvidia_ros_kinetic_cuda8_cudnn6 ## [NVIDIA] Build ROS  Kinetic Container | (CUDA  8     - cuDNN 6)  | OpenCV 3.4.17
	docker build -t $(ORG)/ros-kinetic:cuda8-cudnn6-opencv3 -f nvidia/kinetic/opencv3/Dockerfile .
	@printf "\n\033[92mDocker Image: $(ORG)/ros-kinetic:cuda8-cudnn6-opencv3\033[0m\n"

nvidia_ros_kinetic_cuda10_cudnn7_opencv3: nvidia_ros_kinetic_cuda10_cudnn7 ## [NVIDIA] Build ROS  Kinetic Container | (CUDA 10     - cuDNN 7)  | OpenCV 3.4.17
	docker build -t $(ORG)/ros-kinetic:cuda10-cudnn7-opencv3 -f nvidia/kinetic/opencv3/Dockerfile .
	@printf "\n\033[92mDocker Image: $(ORG)/ros-kinetic:cuda10-cudnn7-opencv3\033[0m\n"

## MELODIC

nvidia_ros_melodic: ## [NVIDIA] Build ROS  Melodic Container
	docker build -t $(ORG)/ros-melodic:nvidia -f nvidia/melodic/base/Dockerfile .
	@printf "\n\033[92mDocker Image: $(ORG)/ros-melodic:nvidia\033[0m\n"

nvidia_ros_melodic_cuda10: nvidia_ros_melodic ## [NVIDIA] Build ROS  Melodic Container | (CUDA 10     - no cuDNN)
	docker build -t $(ORG)/ros-melodic:cuda10 -f nvidia/melodic/cuda10/Dockerfile .
	@printf "\n\033[92mDocker Image: $(ORG)/ros-melodic:cuda10\033[0m\n"

nvidia_ros_melodic_cuda10-1: nvidia_ros_melodic ## [NVIDIA] Build ROS  Melodic Container | (CUDA 10.1   - no cuDNN)
	docker build -t $(ORG)/ros-melodic:cuda10.1 -f nvidia/melodic/cuda10.1/Dockerfile .
	@printf "\n\033[92mDocker Image: $(ORG)/ros-melodic:cuda10.1\033[0m\n"

nvidia_ros_melodic_cuda10_cudnn7: nvidia_ros_melodic_cuda10 ## [NVIDIA] Build ROS  Melodic Container | (CUDA 10     - cuDNN 7)
	docker build -t $(ORG)/ros-melodic:cuda10-cudnn7 -f nvidia/melodic/cuda10/cudnn7/Dockerfile .
	@printf "\n\033[92mDocker Image: $(ORG)/ros-melodic:cuda10-cudnn7\033[0m\n"

nvidia_ros_melodic_cuda10-1_cudnn7: nvidia_ros_melodic_cuda10-1 ## [NVIDIA] Build ROS  Melodic Container | (CUDA 10.1   - cuDNN 7)
	docker build -t $(ORG)/ros-melodic:cuda10.1-cudnn7 -f nvidia/melodic/cuda10.1/cudnn7/Dockerfile .
	@printf "\n\033[92mDocker Image: $(ORG)/ros-melodic:cuda10.1-cudnn7\033[0m\n"
	
nvidia_ros_melodic_cuda11-4-2: nvidia_ros_melodic ## [NVIDIA] Build ROS  Melodic Container | (CUDA 11.4.2 - no cuDNN)
	docker build -t $(ORG)/ros-melodic:cuda11.4.2 -f nvidia/melodic/cuda11.4.2/Dockerfile .
	@printf "\n\033[92mDocker Image: $(ORG)/ros-melodic:cuda11.4.2\033[0m\n"
	
nvidia_ros_melodic_cuda11-4-2_cudnn8: nvidia_ros_melodic_cuda11-4-2 ## [NVIDIA] Build ROS  Melodic Container | (CUDA 11.4.2 - cuDNN 8)
	docker build -t $(ORG)/ros-melodic:cuda11.4.2-cudnn8 -f nvidia/melodic/cuda11.4.2/cudnn8/Dockerfile .
	@printf "\n\033[92mDocker Image: $(ORG)/ros-melodic:cuda11.4.2-cudnn8\033[0m\n"

## NOETIC

nvidia_ros_noetic: ## [NVIDIA] Build ROS  Noetic  Container
	docker build -t $(ORG)/ros-noetic:nvidia -f nvidia/noetic/base/Dockerfile .
	@printf "\n\033[92mDocker Image: $(ORG)/ros-noetic:nvidia\033[0m\n"

nvidia_ros_noetic_cuda11-4-2: nvidia_ros_noetic ## [NVIDIA] Build ROS  Noetic  Container | (CUDA 11.4.2 - no cuDNN)
	docker build -t $(ORG)/ros-noetic:cuda11.4.2 -f nvidia/noetic/cuda11.4.2/Dockerfile .
	@printf "\n\033[92mDocker Image: $(ORG)/ros-noetic:cuda11.4.2\033[0m\n"
	
nvidia_ros_noetic_cuda11-4-2_cudnn8: nvidia_ros_noetic_cuda11-4-2 ## [NVIDIA] Build ROS  Noetic  Container | (CUDA 11.4.2 - cuDNN 8)
	docker build -t $(ORG)/ros-noetic:cuda11.4.2-cudnn8 -f nvidia/noetic/cuda11.4.2/cudnn8/Dockerfile .
	@printf "\n\033[92mDocker Image: $(ORG)/ros-noetic:cuda11.4.2-cudnn8\033[0m\n"

## BOUNCY

nvidia_ros_bouncy: ## [NVIDIA] Build ROS2 Bouncy  Container
	docker build -t $(ORG)/ros-bouncy:latest -f nvidia/bouncy/base/Dockerfile .
	@printf "\n\033[92mDocker Image: $(ORG)/ros-bouncy:latest\033[0m\n"

## Helper TASKS
nvidia_run_help: ## [NVIDIA] Prints help and hints on how to run an [NVIDIA]-based image
	 @printf "\n- Make sure the nvidia-docker-plugin (Test it with: docker run --rm --runtime=nvidia nvidia/cuda:9.0-base nvidia-smi)\n  - Command example:\ndocker run --rm -it --runtime=nvidia --privileged --net=host --ipc=host \\ \n-v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY=$DISPLAY \\ \n-v $HOME/.Xauthority:/root/.Xauthority -e XAUTHORITY=/root/.Xauthority \\ \n-v <PATH_TO_YOUR_CATKIN_WS>:/root/catkin_ws \\ \n-e ROS_IP=<HOST_IP or HOSTNAME> \\ \n$(ORG)/ros-indigo:nvidia\n"


# CPU

## INDIGO
cpu_ros_indigo: ## [CPU]    Build ROS  Indigo  Container
	docker build -t $(ORG)/ros-indigo:cpu -f cpu/indigo/base/Dockerfile .
	@printf "\n\033[92mDocker Image: $(ORG)/ros-indigo:cpu\033[0m\n"

## KINETIC

cpu_ros_kinetic: ## [CPU]    Build ROS  Kinetic Container
	docker build -t $(ORG)/ros-kinetic:cpu -f cpu/kinetic/base/Dockerfile .
	@printf "\n\033[92mDocker Image: $(ORG)/ros-kinetic:cpu\033[0m\n"

## MELODIC

cpu_ros_melodic: ## [CPU]    Build ROS  Melodic Container
	docker build -t $(ORG)/ros-melodic:cpu -f cpu/melodic/base/Dockerfile .
	@printf "\n\033[92mDocker Image: $(ORG)/ros-melodic:cpu\033[0m\n"

## NOETIC

cpu_ros_noetic: ## [CPU]    Build ROS  Noetic  Container
	docker build -t $(ORG)/ros-noetic:cpu -f cpu/noetic/base/Dockerfile .
	@printf "\n\033[92mDocker Image: $(ORG)/ros-noetic:cpu\033[0m\n"

## Helper TASKS
cpu_run_help: ## [CPU]    Prints help and hints on how to run an [CPU]-based image
	 @printf "\nCommand example:\ndocker run --rm -it --runtime=nvidia --privileged --net=host --ipc=host \\ \n--device=/dev/dri:/dev/dri \\ \n-v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY=$DISPLAY \\ \n-v $HOME/.Xauthority:/root/.Xauthority -e XAUTHORITY=/root/.Xauthority \\ \n-v <PATH_TO_YOUR_CATKIN_WS>:/root/catkin_ws \\ \n-e ROS_IP=<HOST_IP or HOSTNAME> \\ \n$(ORG)/ros-indigo:cpu\n"

# TOOLS

tools_vscode: ## [Tools]  Create a new image that contains Visual Studio Code. Use it as "make tools_vscode <existing_docker_image>".
	docker build --build-arg="ARG_FROM=$(RUN_ARGS)" -t $(RUN_ARGS)-vscode tools/vscode
	@printf "\033[92mDocker Image: $(RUN_ARGS)-vscode\033[0m\n"

tools_canutils: ## [Tools]  Create a new image that contains Canutils. Use it as "make tools_canutils <existing_docker_image>".
	docker build --build-arg="ARG_FROM=$(RUN_ARGS)" -t $(RUN_ARGS)-canutils tools/canutils
	@printf "\033[92mDocker Image: $(RUN_ARGS)-canutils\033[0m\n"

tools_cannelloni: ## [Tools]  Create a new image that contains Cannelloni. Use it as "make tools_cannelloni <existing_docker_image>".
	docker build --build-arg="ARG_FROM=$(RUN_ARGS)" -t $(RUN_ARGS)-cannelloni tools/cannelloni
	@printf "\033[92mDocker Image: $(RUN_ARGS)-cannelloni\033[0m\n"

tools_cmake: ## [Tools]  Create a new image that contains CMake. Use it as "make tools_cmake <existing_docker_image>".
	docker build --build-arg="ARG_FROM=$(RUN_ARGS)" -t $(RUN_ARGS)-cmake tools/cmake
	@printf "\033[92mDocker Image: $(RUN_ARGS)-cmake\033[0m\n"
