---
title: Net::IMAP SSL Verify Mode
layout: post
---
Get this error doing IMAP stuff?

<p><code>SSL_connect returned=1 errno=0 state=SSLv3 read server certificate B: certificate verify failed (OpenSSL::SSL::SSLError)</code></p>

Try this:

{% highlight ruby %}
Net::IMAP.new(host, :ssl => { :verify_mode => OpenSSL::SSL::VERIFY_NONE })
{% endhighlight %}

