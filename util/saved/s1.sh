$data=kubectl get services
echo $data
for f in $data ; do
    echo "$f"
done