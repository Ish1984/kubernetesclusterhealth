#!/bin/bash
# This script is used to check kubernetes cluster health check by using a dummy Namespace and Deployment
# It takes the variables value from the Parameterised Jenkins job

echo “ Namespace selected by user: $namespace “
echo “ Creating Namespace …. $namespace”
echo “ “
kubectl create namespace $namespace
sleep 5
nscheck=`kubectl get namespace | grep $namespace | wc -l`
 
If [  “$nscheck” -eq 1 ]
	then
		echo “ Namespace $namespace created successfully … “
		echo “ “
		echo “ Going for Haproxy Deployment in Namespace $namespace “
		kubectl apply -f deployment.yaml -n $namespace
                 replica=`cat Deployment.yaml|grep replicas|awk '{print $2}'`
         if [ “$replica” -gt 0 ]
           then
		       podcount = `kubectl get deployment -n $namespace |awk '{print $4}'|tail -1f`
                runningpod = ‘kubectl get po -n $namespace|awk '{if(NR>1)print}'|wc -l’ 
                status = `kubectl get po -n $namespace|awk '{if(NR>1)print}'|awk '{print $3}'|sort|uniq`
			    deplname = `kubectl get deployment -n dev|awk '{if(NR>1)print}'|awk '{print $1}’`   
                  if [ “$podcount” -eq “$replica” ] && [ “$runningpod” -eq “$replica” ] && [ “$status” == “Running” ]
                     then
  						echo “ Deployment Successfull “
						sleep 10
                          echo “ Deleting Deployment ... “
						 echo “ “
						 kubectl delete deployment $deplname -n $namespace
						 check=`kubectl get deployment -n $namespace|wc -l`
					     if [ “$check” -eq 0 ]
                              then
							echo “ Deployment Deletion Completed “
							echo “ “
							echo “ Deleting namespace “
							echo “ “
							kubectl delete namespace $namespace
								nsdel=`kubectl get namespaces | grep $namespace |wc -l`
								if [ “$nsdel” -eq 0 ]
   									then
									echo “ Namespace Deleted “
									echo “ “	
									else
									echo “ Namespace Deletion Failed … “
									exit
                             	     fi
                              else
							echo “ Deployment Deletion Failed … “
							echo “ “
							exit
						fi
					else
					echo “ Deployment Failed .. “
				    exit
			else
             echo “ Replica count not as per Deployment yaml … “
  			echo “ “
			exit
		fi
     else
	 echo “ Namespace not created … “
     echo “ “
fi