# VATIC-DOCKER-Contrib

This is a Docker build of the `contrib` branch of [VATIC](https://github.com/cvondrick/vatic/tree/contrib) using the supported install script as much as possible.

I've tested this container for local work only, using Docker 17.03 on MacOS Sierra.

When using this software, please cite the authors:

```
Carl Vondrick, Donald Patterson, Deva Ramanan. "Efficiently Scaling Up
Crowdsourced Video Annotation" International Journal of Computer Vision
(IJCV). June 2012.
```

## Quickstart Guide

Create a data folder to share with docker:
```
DATA_DIR=`pwd`/data/
mkdir -p $DATA_DIR
```

Start the VATIC server using

```
docker run -it -p 8080:80 -v $DATA_DIR:/home/vagrant/vagrant_data jldowns/vatic-docker-contrib:0.1
```

This should open up a shell inside the container. Start the MySQL and Apache services by executing
```
/home/vagrant/start_services.sh
```

### Extracting Frames

Copy a video into `DATA_DIR` and run the following command to extract the frames into a directory called `your_video`:
```
cd /home/vagrant/vatic
turkic extract /home/vagrant/vagrant_data/your_video.mp4 /home/vagrant/vagrant_data/your_video_frames/
```

> Note that right now the `turkic` command only works while in the `/home/vagrant/vatic` directory.

### Load and Publish

The following command loads a directory of frames into VATIC, and sets the labels. `job_id` is a unique handle you set to reference this job.
```
turkic load job_id /home/vagrant/vagrant_data/your_video_frames/ car skateboard airplane --offline
```


VATIC automatically splits long videos into smaller pieces. Each piece gets its own unique URL. To see all the URLs you can type:
```
turkic publish --offline
```

This will return something along the lines of
```
http://localhost/?id=1&hitId=offline
http://localhost/?id=2&hitId=offline
http://localhost/?id=3&hitId=offline
http://localhost/?id=4&hitId=offline
http://localhost/?id=5&hitId=offline
```

When accessing those URLs on your host machine, make sure you include the port number. If you used the command above, you would go to `http://localhost:8080/?id=1&hitId=offline` to start annotating the first video.

## Reading the annotations

After annotating each segment, VATIC will save the annotation in a machine readable format by typing:
```
turkic dump job_id -o /home/vagrant/vagrant_data/annotations.txt
```

If you prefer JSON, you can save the annotations as JSON with the following:
```
turkic dump job_id -o /home/vagrant/vagrant_data/annotations.json --json
```

Full syntax and features are covered in depth at https://github.com/cvondrick/vatic/tree/contrib.



## FAQ

### I get the error `No handlers could be found for logger "turkic.geolocation"`

Make sure you are in the /home/vagrant/vatic directory before running the `turkic` command.

### I accidentally exited before dumping the annotations!

Find the container you just stopped by typing
```
docker ps -a
```

You can then restart and reattach the container and dump your data by typing
```
docker start $JOB
docker attach $JOB
```

where `$JOB` is the container ID.
