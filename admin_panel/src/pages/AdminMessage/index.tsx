import React, { useEffect, useState } from "react";
import { Container } from "reactstrap";
import BreadCrumb from "Components/Common/BreadCrumb";
import { Card, Col, Row, List, Avatar, Input, Button, Typography, Spin, Empty } from 'antd';
import axios from "axios";
import { ToastContainer, toast } from 'react-toastify';
import 'react-toastify/dist/ReactToastify.css';

const { Text } = Typography;
const { Search } = Input;

interface UserType {
  key: string;
  id: string;
  email: string;
  username: string;
  user_created: string | null;
  is_active: boolean;
}

interface MessageType {
  id: string;
  sender_id: string;
  receiver_id: string;
  message: string;
  timestamp: string;
  is_from_admin: boolean;
}

const AdminMessage = () => {
  const [users, setUsers] = useState<UserType[]>([]);
  const [filteredUsers, setFilteredUsers] = useState<UserType[]>([]);
  const [selectedUser, setSelectedUser] = useState<UserType | null>(null);
  const [messages, setMessages] = useState<MessageType[]>([]);
  const [newMessage, setNewMessage] = useState<string>("");
  const [loading, setLoading] = useState<boolean>(false);
  const [searchText, setSearchText] = useState<string>("");

  const getAuthToken = () => {
    const authUser = sessionStorage.getItem("authUser");
    if (authUser) {
      const parsedUser = JSON.parse(authUser);
      return parsedUser.token;
    }
    return null;
  };

  // Fetch all users
  useEffect(() => {
    const fetchUserData = async () => {
      setLoading(true);
      const token = getAuthToken();
      if (!token) {
        console.error("No token found in sessionStorage");
        setLoading(false);
        return;
      }
  
      const headers = {
        Authorization: `Token ${token}`,
      };
  
      try {
        const response = await axios.get(`${process.env.REACT_APP_API_URL}/admin/active-users`, { headers });
        const transformedData = response.data.map((user: any) => ({
          key: user.id,
          id: user.id,
          email: user.email,
          username: user.username,
          user_created: user.user_created || 'N/A',
          is_active: user.is_active,
        }));
        setUsers(transformedData);
        setFilteredUsers(transformedData);
        setLoading(false);
      } catch (error) {
        console.error('Error fetching user data:', error);
        toast.error("Failed to fetch users");
        setLoading(false);
      }
    };
  
    fetchUserData();
  }, []);

  // Filter users based on search text
  useEffect(() => {
    if (searchText) {
      const filtered = users.filter(
        user => 
          user.username.toLowerCase().includes(searchText.toLowerCase()) || 
          user.email.toLowerCase().includes(searchText.toLowerCase())
      );
      setFilteredUsers(filtered);
    } else {
      setFilteredUsers(users);
    }
  }, [searchText, users]);

  // Fetch messages for selected user
  useEffect(() => {
    if (selectedUser) {
      fetchMessages(selectedUser.id);
    }
  }, [selectedUser]);

  const fetchMessages = async (userId: string) => {
    setLoading(true);
    const token = getAuthToken();
    if (!token) {
      console.error("No token found in sessionStorage");
      setLoading(false);
      return;
    }

    const headers = {
      Authorization: `Token ${token}`,
    };

    try {
      // This is a placeholder - replace with your actual API endpoint
      const response = await axios.get(
        `${process.env.REACT_APP_API_URL}/admin/messages/${userId}`, 
        { headers }
      );
      console.log("API response:", response);
      setMessages(response.data || []);
      setLoading(false);
    } catch (error) {
      console.error('Error fetching messages:', error);
      console.log("API error:", error);
    }
    // For demo purposes, set some dummy messages
    // setMessages([
    //   {
    //     id: '1',
    //     sender_id: userId,
    //     receiver_id: 'admin',
    //     message: 'Hello, I need some help with my account.',
    //     timestamp: new Date().toISOString(),
    //     is_admin: false
    //   },
    //   {
    //     id: '2',
    //     sender_id: 'admin',
    //     receiver_id: userId,
    //     message: 'Hi there! How can I assist you today?',
    //     timestamp: new Date().toISOString(),
    //     is_admin: true
    //   }
    // ]);
    setLoading(false);
  };

  const handleUserSelect = (user: UserType) => {
    console.log("selected user" ,user);
    
    setSelectedUser(user);
  };

  const handleSendMessage = async () => {
    if (!newMessage.trim() || !selectedUser) return;
  
    const token = getAuthToken();
    if (!token) {
      console.error("No token found in sessionStorage");
      return;
    }
  
    const headers = {
      Authorization: `Token ${token}`,
    };
  
    const messageData = {
      message: newMessage,
      receiver_id: selectedUser.id,
    };
  
    try {
      const response = await axios.post(
        `${process.env.REACT_APP_API_URL}/admin/send-message`,
        messageData,
        { headers }
      );

      console.log("Message sent successfully. Response:", selectedUser);

      // if (response.status >= 200 && response.status < 300) {
        const newMsg: MessageType = {
          id: response.data.id, // use backend ID if returned
          sender_id: 'admin',
          receiver_id: selectedUser.id,
          message: newMessage,
          timestamp: new Date().toISOString(),
          is_from_admin: true,
        };
        toast.success("Message sent successfully!");
        setMessages(prevMessages => [...prevMessages, newMsg]);
        setNewMessage("");
        fetchMessages(selectedUser.id);
      // } else {
      //   console.error("API returned an error status:", response.status);
      // }
    } catch (error: any) {
      console.error('Error sending message:', error);
      console.log("Error details:", error.response);
      toast.error("Failed to send message.");
    }
  };
  // const handleSendMessage = async () => {
  //   if (!newMessage.trim() || !selectedUser) return;

  //   const token = getAuthToken();
  //   if (!token) {
  //     console.error("No token found in sessionStorage");
  //     return;
  //   }

  //   const headers = {
  //     Authorization: `Token ${token}`,
  //   };

  //   const messageData = {
  //     message: newMessage,
  //     receiver_id: selectedUser.id
  //   };

  //   try {
  //     // This is a placeholder - replace with your actual API endpoint
  //     await axios.post(
  //       `${process.env.REACT_APP_API_URL}/admin/send-message`, 
  //       messageData,
  //       { headers }
  //     );
      
  //     // Add the new message to the messages list
  //     const newMsg: MessageType = {
  //       id: Date.now().toString(),
  //       sender_id: 'admin',
  //       receiver_id: selectedUser.id,
  //       message: newMessage,
  //       timestamp: new Date().toISOString(),
  //       is_admin: true
  //     };
      
  //     setMessages(prevMessages => [...prevMessages, newMsg]);
  //     setNewMessage("");
  //   } catch (error) {
  //     console.error('Error sending message:', error);
  //     toast.error("Failed to send message");
      
  //     // For demo purposes, still add the message to the UI
  //     const newMsg: MessageType = {
  //       id: Date.now().toString(),
  //       sender_id: 'admin',
  //       receiver_id: selectedUser.id,
  //       message: newMessage,
  //       timestamp: new Date().toISOString(),
  //       is_admin: true
  //     };
      
  //     setMessages(prevMessages => [...prevMessages, newMsg]);
  //     setNewMessage("");
  //   }
  // };

  const formatTimestamp = (timestamp: string) => {
    const date = new Date(timestamp);
    return date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
  };

  return (
    <React.Fragment>
      <div className="page-content">
        <Container fluid>
          <ToastContainer />
          <BreadCrumb title="Admin Chat" pageTitle="Chat" />

          <Row gutter={16}>
            {/* Left Side - User List */}
            <Col xs={24} sm={24} md={8} lg={6}>
              <Card 
                title="Users" 
                bordered={false} 
                className="chat-leftsidebar"
                extra={
                  <Search
                    placeholder="Search users"
                    onChange={(e) => setSearchText(e.target.value)}
                    style={{ width: 200 }}
                  />
                }
              >
                {loading && !selectedUser ? (
                  <div style={{ textAlign: 'center', padding: '20px' }}>
                    <Spin />
                  </div>
                ) : (
                  <List
                    className="chat-room-list"
                    itemLayout="horizontal"
                    dataSource={filteredUsers}
                    renderItem={(user) => (
                      <List.Item 
                        onClick={() => handleUserSelect(user)}
                        className={`chat-list ${selectedUser?.id === user.id ? 'active' : ''}`}
                        style={{ 
                          cursor: 'pointer', 
                          padding: '10px',
                          backgroundColor: selectedUser?.id === user.id ? 'rgba(var(--bs-primary-rgb), 0.15)' : 'transparent'
                        }}
                      >
                        <List.Item.Meta
                          avatar={
                            <Avatar 
                              style={{ 
                                backgroundColor: user.is_active ? '#52c41a' : '#ff4d4f',
                                border: '2px solid #fff'
                              }}
                            >
                              {user.username.charAt(0).toUpperCase()}
                            </Avatar>
                          }
                          title={<Text strong>{user.username}</Text>}
                          description={
                            <Text type="secondary" ellipsis>{user.email}</Text>
                          }
                        />
                       
                      </List.Item>
                    )}
                  />
                )}
              </Card>
            </Col>

            {/* Right Side - Chat Area */}
            <Col xs={24} sm={24} md={16} lg={18}>
              <Card 
                bordered={false} 
                className="user-chat"
                title={
                  selectedUser ? (
                    <div className="user-chat-topbar">
                      <Avatar 
                        style={{ 
                          backgroundColor: selectedUser.is_active ? '#52c41a' : '#ff4d4f',
                          marginRight: '10px'
                        }}
                      >
                        {selectedUser.username.charAt(0).toUpperCase()}
                      </Avatar>
                      <div>
                        <Text strong>{selectedUser.username}</Text>
                        <br />
                        <Text type="secondary" style={{ fontSize: '12px' }}>
                          {selectedUser.email}
                        </Text>
                      </div>
                    </div>
                  ) : "Select a user to start chatting"
                }
              >
                {selectedUser ? (
                  <>
                    <div 
                      className="chat-conversation" 
                      style={{ 
                        height: 'calc(100vh - 350px)', 
                        overflowY: 'auto',
                        padding: '20px',
                        backgroundImage: 'url("../../assets/images/chat-bg-pattern.png")'
                      }}
                    >
                      {loading ? (
                        <div style={{ textAlign: 'center', padding: '20px' }}>
                          <Spin />
                        </div>
                      ) : messages.length > 0 ? (
                        <List
                          className="chat-conversation-list"
                          itemLayout="horizontal"
                          dataSource={messages}
                          renderItem={(message) => {
                            console.log("Message data:", message);
                            return (
                                <List.Item
                                style={{ 
                                  display: 'flex', 
                                  justifyContent: message.is_from_admin ? 'flex-end' : 'flex-start',
                                  padding: '5px 0'
                                }}
                              >
                                <div 
                                  style={{ 
                                    maxWidth: '70%',
                                    padding: '10px 15px',
                                    borderRadius: message.is_from_admin ? '15px 15px 0 15px' : '15px 15px 15px 0',
                                    backgroundColor: message.is_from_admin ? 'rgba(var(--bs-primary-rgb), 0.15)' : '#f0f0f0',
                                    color: message.is_from_admin ? 'var(--bs-primary)' : 'inherit'
                                  }}
                                >
                                  <div>{message.message}</div>
                                  <div style={{ fontSize: '10px', textAlign: 'right', marginTop: '5px' }}>
                                    {formatTimestamp(message.timestamp)}
                                  </div>
                                </div>
                              </List.Item>
                            );
                          }}
                        />
                      ) : (
                        <Empty description="No messages yet" />
                      )}
                    </div>
                    <div className="chat-input-section" style={{ padding: '15px', borderTop: '1px solid #f0f0f0' }}>
                      <Row gutter={8}>
                        <Col flex="auto">
                          <Input.TextArea 
                            value={newMessage}
                            onChange={(e) => setNewMessage(e.target.value)}
                            placeholder="Type your message..."
                            autoSize={{ minRows: 1, maxRows: 3 }}
                            onPressEnter={(e) => {
                              if (!e.shiftKey) {
                                e.preventDefault();
                                handleSendMessage();
                              }
                            }}
                          />
                        </Col>
                        <Col>
                          <Button 
                            type="primary" 
                            onClick={handleSendMessage}
                            disabled={!newMessage.trim()}
                          >
                            Send
                          </Button>
                        </Col>
                      </Row>
                    </div>
                  </>
                ) : (
                  <div style={{ 
                    height: 'calc(100vh - 300px)', 
                    display: 'flex', 
                    justifyContent: 'center', 
                    alignItems: 'center',
                    flexDirection: 'column'
                  }}>
                    <Empty description="Select a user to start chatting" />
                  </div>
                )}
              </Card>
            </Col>
          </Row>
        </Container>
      </div>
    </React.Fragment>
  );
}

export default AdminMessage;
