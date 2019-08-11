# PipelineDemo

Exercise application for studying GenStage and LiveView.

My purpose was to build pipeline using gen stage.
Pipeline contains from one producer and variable amount of consumers.
Every consumer after spawning and activating demand one element per second from producer.
So the amount of consumers increase amount of processed events. 
To visualise it i have used LiveView. Please visit /experiment

## Up and running

mix deps.get
cd assets 
npm i
cd ..
mix phx.server
