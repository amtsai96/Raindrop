using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FlockManager : MonoBehaviour
{
    [Header("Fish Settings")]
    [Range(0.0f, 5.0f)]
    public float minSpeed;
    [Range(0.0f, 5.0f)]
    public float maxSpeed;
    [Range(1.0f, 2.0f)]
    public float neighbourDistance;
    [Range(0.0f, 5.0f)]
    public float rotationSpeed;

    public GameObject fishPrefab;                    //公共變量
    public int numFish = 50;                         // 
    public GameObject[] allFish;                     //檢查器窗口更改魚的數量。然後創建一個allFish數組。當他們被實例化時，他們會去，也就是魚的數量將進入allFish數組
    public Vector3 swimLimits = new Vector3(4, 6, 5);

    // Use this for initialization
    void Start()
    {
        allFish = new GameObject[numFish];
        for (int i = 0; i < numFish; i++)
        {
            Vector3 pos = new Vector3(this.transform.position.x + Random.Range(-swimLimits.x, swimLimits.x), -this.transform.position.y - Random.Range(-swimLimits.y, swimLimits.y), -3);/*new Vector3(Random.Range(-swimLimits.x, swimLimits.x),
                                                                  Random.Range(-swimLimits.y, swimLimits.y),
                                                                  Random.Range(-swimLimits.z, swimLimits.z));*/
            allFish[i] = (GameObject)Instantiate(fishPrefab, pos, Quaternion.identity);
            allFish[i].GetComponent<Flock>().myManager = this;
        }

    }

    // Update is called once per frame
    void Update()
    {

    }
}